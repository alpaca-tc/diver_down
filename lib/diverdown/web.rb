# frozen_string_literal: true

require 'rack'
require 'yaml'

module Diverdown
  class Web
    WEB_DIR = File.expand_path('../../web', __dir__)

    require 'diverdown/web/action'
    require 'diverdown/web/definition_to_dot'
    require 'diverdown/web/concurrency_worker'
    require 'diverdown/web/definition_enumerator'
    require 'diverdown/web/bit_id'

    # For development
    autoload :DevServerMiddleware, 'diverdown/web/dev_server_middleware'

    M = Mutex.new

    # @param definition_dir [String]
    # @param store [Diverdown::DefinitionStore]
    def initialize(definition_dir:, store: Diverdown::DefinitionStore.new)
      @definition_dir = definition_dir
      @store = store
      @files_server = Rack::Files.new(File.join(WEB_DIR))
    end

    # @param env [Hash]
    # @return [Array[Integer, Hash, Array]]
    def call(env)
      request = Rack::Request.new(env)
      action = Diverdown::Web::Action.new(store: @store, request:)

      if @store.empty?
        M.synchronize do
          load_store if @store.empty?
        end
      end

      case [request.request_method, request.path]
      in ['GET', %r{\A/api/definitions\.json\z}]
        action.definitions(
          page: request.params['page']&.to_i || 1,
          per: request.params['per']&.to_i || 100,
          query: request.params['query'] || ''
        )
      in ['GET', %r{\A/api/definitions/(?<bit_id>\d+)\.json\z}]
        bit_id = Regexp.last_match[:bit_id].to_i
        action.combine_definitions(bit_id)
      in ['GET', %r{\A/api/sources/(?<source>.+)\.json\z}]
        source = Regexp.last_match[:source]
        action.source(source)
      in ['GET', '/']
        @files_server.call(env.merge('PATH_INFO' => '/index.html'))
      else
        @files_server.call(env)
      end
    end

    private

    def load_store
      # TODO: Optimize load yaml
      # TODO: How to implement packages and modules...
      # TODO: Loading all yaml is slow. Need to filter to load only wanted yaml.
      files = Dir[File.join(@definition_dir, '**', '*.msgpack')].sort.first(1000)

      concurrency_worker = Diverdown::Web::ConcurrencyWorker.new(concurrency: 30)
      concurrency_worker.run(files) do |path|
        hash = Diverdown::Helper.deep_symbolize_keys(MessagePack.unpack(File.binread(path)))
        definition = Diverdown::Definition.from_hash(hash)
        @store.set(definition)
      end

      puts 'store loaded!'
    end
  end
end
