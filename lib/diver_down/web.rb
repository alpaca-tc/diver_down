# frozen_string_literal: true

require 'rack'
require 'yaml'

module DiverDown
  class Web
    WEB_DIR = File.expand_path('../../web', __dir__)

    require 'diver_down/web/action'
    require 'diver_down/web/definition_to_dot'
    require 'diver_down/web/definition_enumerator'
    require 'diver_down/web/bit_id'
    require 'diver_down/web/module_store'
    require 'diver_down/web/indented_string_io'
    require 'diver_down/web/definition_store'
    require 'diver_down/web/definition_loader'

    # For development
    autoload :DevServerMiddleware, 'diver_down/web/dev_server_middleware'

    # @param definition_dir [String]
    # @param module_store [DiverDown::ModuleStore]
    # @param store [DiverDown::Web::DefinitionStore]
    def initialize(definition_dir:, module_store:, store: DiverDown::Web::DefinitionStore.new)
      @store = store
      @module_store = module_store
      @files_server = Rack::Files.new(File.join(WEB_DIR))

      definition_files = ::Dir["#{definition_dir}/**/*.{yml,yaml,msgpack,json}"].sort
      @total_definition_files_size = definition_files.size

      load_definition_files_on_thread(definition_files)
    end

    # @param env [Hash]
    # @return [Array[Integer, Hash, Array]]
    def call(env)
      request = Rack::Request.new(env)
      action = DiverDown::Web::Action.new(store: @store, module_store: @module_store, request:)

      case [request.request_method, request.path]
      in ['GET', %r{\A/api/definitions\.json\z}]
        action.definitions(
          page: request.params['page']&.to_i || 1,
          per: request.params['per']&.to_i || 100,
          title: request.params['title'] || '',
          source: request.params['source'] || '',
          definition_group: request.params['definition_group'] || ''
        )
      in ['GET', %r{\A/api/sources\.json\z}]
        action.sources
      in ['GET', %r{\A/api/modules\.json\z}]
        action.modules
      in ['GET', %r{\A/api/modules/(?<module_names>.+)\.json\z}]
        module_names = CGI.unescape(Regexp.last_match[:module_names]).split('/')
        action.module(module_names)
      in ['GET', %r{\A/api/definitions/(?<bit_id>\d+)\.json\z}]
        bit_id = Regexp.last_match[:bit_id].to_i
        compound = request.params['compound'] == '1'
        concentrate = request.params['concentrate'] == '1'
        only_module = request.params['only_module'] == '1'
        action.combine_definitions(bit_id, compound, concentrate, only_module)
      in ['GET', %r{\A/api/sources/(?<source>[^/]+)\.json\z}]
        source = Regexp.last_match[:source]
        action.source(source)
      in ['POST', %r{\A/api/sources/(?<source>[^/]+)/modules.json\z}]
        source = Regexp.last_match[:source]
        modules = request.params['modules'] || []
        action.set_modules(source, modules)
      in ['GET', %r{\A/api/pid\.json\z}]
        action.pid
      in ['GET', %r{\A/api/initialization_status\.json\z}]
        action.initialization_status(@total_definition_files_size)
      in ['GET', %r{\A/assets/}]
        @files_server.call(env)
      in ['GET', /\.json\z/], ['POST', /\.json\z/]
        action.not_found
      else
        @files_server.call(env.merge('PATH_INFO' => '/index.html'))
      end
    end

    private

    def load_definition_files_on_thread(definition_files)
      definition_loader = DiverDown::Web::DefinitionLoader.new

      Thread.new do
        loop do
          break if definition_files.empty?

          definition_file = definition_files.shift
          definition = definition_loader.load_file(definition_file)

          # No needed to synchronize because this is executed on a single thread.
          @store.set(definition)
        end
      end
    end
  end
end
