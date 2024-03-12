# frozen_string_literal: true

require 'rack'
require 'yaml'

module Diverdown
  class WebApplication
    WEB_DIR = File.expand_path('../../web', __dir__)

    require 'diverdown/web_application/action'

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
      action = Diverdown::WebApplication::Action.new(store: @store, request:)

      case [request.request_method, request.path]
      in ['GET', /\.(?:js|css)\z/]
        @files_server.call(env)
      in ['GET', '/']
        reload_store
        action.index
      in ['POST', '/definitions/combine.json']
        ids = request.params['ids'].to_s.split(',')
        action.combine_definitions(ids)
      else
        action.not_found
      end
    end

    private

    def reload_store
      @store.clear

      Dir[File.join(@definition_dir, '**', '*.{yml,yaml}')].sort.each do
        hash = YAML.safe_load(File.read(_1), permitted_classes: [Symbol], symbolize_names: true)
        definition = Diverdown::Definition.from_hash(hash)
        @store.set(definition)
      end

      @store.each do |definition|
        *parent_ids, _ = definition.id.split(':')
        parent_id = parent_ids.join(':')

        next if parent_id.empty?

        unless @store.key?(parent_id)
          @store.set(
            Diverdown::Definition.new(
              id: parent_id,
              title: parent_id,
              sources: []
            )
          )
        end

        parent_definition = @store.get(parent_id)
        definition.parent = parent_definition
      end
    end
  end
end
