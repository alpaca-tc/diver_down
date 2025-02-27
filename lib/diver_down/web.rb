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
    require 'diver_down/web/metadata'
    require 'diver_down/web/indented_string_io'
    require 'diver_down/web/definition_store'
    require 'diver_down/web/definition_loader'
    require 'diver_down/web/definition_module_dependencies'
    require 'diver_down/web/source_alias_resolver'
    require 'diver_down/web/definition_filter'

    # For development
    autoload :DevServerMiddleware, 'diver_down/web/dev_server_middleware'

    # @return [DiverDown::Web::DefinitionStore]
    def self.store
      @store ||= DiverDown::Web::DefinitionStore.new
    end

    # @param definition_dir [String]
    # @param metadata [DiverDown::Web::Metadata]
    # @param blob_prefix [String]
    # @param store [DiverDown::Web::DefinitionStore]
    def initialize(definition_dir:, metadata:, blob_prefix:)
      @metadata = metadata
      @blob_prefix = blob_prefix&.sub(%r{/+$}, '')
      @files_server = Rack::Files.new(File.join(WEB_DIR))

      definition_files = ::Dir["#{definition_dir}/**/*.{yml,yaml,msgpack,json}"].sort
      @total_definition_files_size = definition_files.size
      @action = nil

      load_definition_files_on_thread(definition_files)
    end

    # @param env [Hash]
    # @return [Array[Integer, Hash, Array]]
    def call(env)
      request = Rack::Request.new(env)

      if @action&.store.object_id != self.class.store.object_id
        @action = DiverDown::Web::Action.new(store: self.class.store, metadata: @metadata, blob_prefix: @blob_prefix)
      end

      case [request.request_method, request.path]
      in ['GET', %r{\A/api/definitions\.json\z}]
        @action.definitions(
          page: request.params['page']&.to_i || 1,
          per: request.params['per']&.to_i || 100,
          title: request.params['title'] || '',
          source: request.params['source'] || '',
          definition_group: request.params['definition_group'] || ''
        )
      in ['GET', %r{\A/api/sources\.json\z}]
        @action.sources
      in ['GET', %r{\A/api/modules\.json\z}]
        @action.modules
      in ['GET', %r{\A/api/modules/(?<modulee>[^/]+)\.json\z}]
        modulee = CGI.unescape(Regexp.last_match[:modulee])
        @action.module(modulee)
      in ['GET', %r{\A/api/definitions/(?<bit_id>\d+)\.json\z}]
        bit_id = Regexp.last_match[:bit_id].to_i
        compound = request.params['compound'] == '1'
        concentrate = request.params['concentrate'] == '1'
        only_module = request.params['only_module'] == '1'
        remove_internal_sources = request.params['remove_internal_sources'] == '1'
        focus_modules = request.params['focus_modules'] || []
        modules = request.params['modules'] || []
        @action.combine_definitions(bit_id, compound, concentrate, only_module, remove_internal_sources, focus_modules, modules)
      in ['GET', %r{\A/api/sources/(?<source>[^/]+)\.json\z}]
        source = Regexp.last_match[:source]
        @action.source(source)
      in ['GET', %r{\A/api/reload\.json\z}]
        @action.reload_cache
      in ['POST', %r{\A/api/sources/(?<source>[^/]+)/module.json\z}]
        source = Regexp.last_match[:source]
        modulee = request.params['module'] || ''
        @action.set_module(source, modulee)
      in ['POST', %r{\A/api/sources/(?<source>[^/]+)/memo.json\z}]
        source = Regexp.last_match[:source]
        memo = request.params['memo'] || ''
        @action.set_memo(source, memo)
      in ['POST', %r{\A/api/modules/(?<from_module>[^/]+)/dependency_types/(?<to_module>[^/]+)\.json\z}]
        from_module = CGI.unescape(Regexp.last_match[:from_module])
        to_module = CGI.unescape(Regexp.last_match[:to_module])
        dependency_type = request.params['dependency_type']

        @action.update_module_dependency_type(from_module, to_module, dependency_type)
      in ['POST', %r{\A/api/sources/(?<from_source>[^/]+)/dependency_types/(?<to_source>[^/]+)\.json\z}]
        from_source = Regexp.last_match[:from_source]
        to_source = Regexp.last_match[:to_source]
        dependency_type = request.params['dependency_type']

        @action.update_source_dependency_type(from_source, to_source, dependency_type)
      in ['GET', %r{\A/api/pid\.json\z}]
        @action.pid
      in ['GET', %r{\A/api/initialization_status\.json\z}]
        @action.initialization_status(@total_definition_files_size)
      in ['GET', %r{\A/api/configuration\.json\z}]
        @action.configuration
      in ['GET', %r{\A/api/source_aliases\.json\z}]
        @action.source_aliases
      in ['POST', %r{\A/api/source_aliases\.json\z}]
        alias_name = request.params['alias_name']
        old_alias_name = request.params['old_alias_name'] # NOTE: nillable
        source_names = request.params['source_names'] || []

        @action.update_source_alias(alias_name, old_alias_name, source_names)
      in ['GET', %r{\A/assets/}]
        @files_server.call(env)
      in ['GET', /\.json\z/], ['POST', /\.json\z/]
        @action.not_found
      else
        @files_server.call(env.merge('PATH_INFO' => '/index.html'))
      end
    end

    private

    def load_definition_files_on_thread(definition_files)
      definition_loader = DiverDown::Web::DefinitionLoader.new
      store = self.class.store

      Thread.new do
        loop do
          break if definition_files.empty?

          # If store is changed in test, stop loading.
          break if store != self.class.store

          definition_file = definition_files.shift
          definition = definition_loader.load_file(definition_file)

          # No needed to synchronize because this is executed on a single thread.
          store.set(definition)
        end

        # Cache combined_definition
        store.combined_definition

        # For development
        if ENV['DIVER_DOWN_DIR']
          File.write(File.expand_path('../../tmp/combined_definition.yml', __dir__), store.combined_definition.to_h.to_yaml)
        end
      end
    end
  end
end
