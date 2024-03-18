# frozen_string_literal: true

require 'rack'
require 'yaml'

module Diverdown
  class Web
    WEB_DIR = File.expand_path('../../web', __dir__)

    require 'diverdown/web/action'
    require 'diverdown/web/definition_to_dot'
    require 'diverdown/web/concurrency_worker'

    # @param definition_dir [String]
    # @param store [Diverdown::DefinitionStore]
    def initialize(definition_dir:, store: Diverdown::DefinitionStore.new)
      @definition_dir = definition_dir
      @store = store
      @files_server = Rack::Files.new(File.join(WEB_DIR, 'public'))
    end

    # @param env [Hash]
    # @return [Array[Integer, Hash, Array]]
    def call(env)
      request = Rack::Request.new(env)
      action = Diverdown::Web::Action.new(store: @store, request:)

      load_store if @store.empty?

      case [request.request_method, request.path]
      in ['GET', /\.(?:js|css)\z/]
        @files_server.call(env)
      in ['GET', '/']
        action.index
      in ['GET', %r{\A/definitions/(?<bit_id>\d+)\.json\z}]
        bit_id = Regexp.last_match[:bit_id].to_i
        action.combine_definitions(bit_id)
      in ['GET', %r{\A/sources/(?<source>.+)\z}]
        source = Regexp.last_match[:source]
        action.source(source)
      else
        action.not_found
      end
    end

    private

    def load_store
      # TODO: Optimize load yaml
      # TODO: How to implement packages and modules...
      packages = Hash.new { |h, k| h[k] = [] }
      yaml_files = Dir[File.join(@definition_dir, '**', '*.{yml,yaml}')].sort

      concurrency_worker = Diverdown::Web::ConcurrencyWorker.new(concurrency: 30)
      concurrency_worker.run(yaml_files) do |path|
        hash = YAML.safe_load(File.read(path), permitted_classes: [Symbol], symbolize_names: true)
        definition = Diverdown::Definition.from_hash(hash)
        @store.set(definition)
        packages[hash[:package]].push(definition)
        puts "#{yaml_files.index(path) / yaml_files.size.to_f * 100}%"
      end

      packages.each do |package, definitions|
        package_definition = Diverdown::Definition.new(
          title: package,
          sources: []
        )

        @store.set(package_definition)

        definitions.each do |definition|
          definition.parent = package_definition
        end
      end

      puts 'store loaded!'
    end
  end
end
