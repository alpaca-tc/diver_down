# frozen_string_literal: true

require 'json'

module DiverDown
  class Web
    class Action
      Pagination = Data.define(
        :current_page,
        :total_pages,
        :total_count,
        :per
      )

      # @param store [DiverDown::Definition::Store]
      # @param module_store [DiverDown::Web::ModuleStore]
      # @param request [Rack::Request]
      def initialize(store:, module_store:, request:)
        @store = store
        @module_store = module_store
        @request = request
      end

      # GET /api/sources.json
      def sources
        source_names = Set.new

        # rubocop:disable Style/HashEachMethods
        @store.each do |_, definition|
          definition.sources.each do |source|
            source_names.add(source.source_name)
          end
        end
        # rubocop:enable Style/HashEachMethods

        classified_sources_count = source_names.count { @module_store.include?(_1) }

        json(
          sources: source_names.sort.map do |source_name|
            {
              source_name:,
              modules: @module_store.get(source_name).map do |module_name|
                { module_name: }
              end,
            }
          end,
          classified_sources_count:
        )
      end

      # GET /api/modules.json
      def modules
        # Hash{ DiverDown::Definition::Modulee => Set<Integer> }
        module_set = Set.new

        # rubocop:disable Style/HashEachMethods
        @store.each do |_, definition|
          definition.sources.each do |source|
            modules = @module_store.get(source.source_name)
            module_set.add(modules) unless modules.empty?
          end
        end
        # rubocop:enable Style/HashEachMethods

        json(
          modules: module_set.sort.map do
            _1.map do |module_name|
              {
                module_name:,
              }
            end
          end
        )
      end

      # GET /api/modules/:module_name.json
      # @param module_names [Array<String>]
      def module(module_names)
        # Hash{ DiverDown::Definition::Modulee => Set<Integer> }
        related_definition_store_ids = Set.new
        source_names = Set.new

        # rubocop:disable Style/HashEachMethods
        @store.each do |_, definition|
          definition.sources.each do |source|
            source_module_names = @module_store.get(source.source_name)

            next unless source_module_names[0..module_names.size - 1] == module_names

            source_names.add(source.source_name)
            related_definition_store_ids.add(definition.store_id)
          end
        end
        # rubocop:enable Style/HashEachMethods

        if related_definition_store_ids.empty?
          return not_found
        end

        related_definitions = related_definition_store_ids.map { @store.get(_1) }

        json(
          modules: module_names.map do
            {
              module_name: _1,
            }
          end,
          sources: source_names.sort.map do |source_name|
            {
              source_name:,
            }
          end,
          related_definitions: related_definitions.map do |definition|
            {
              id: definition.store_id,
              title: definition.title,
            }
          end
        )
      end

      # GET /api/definitions.json
      #
      # @param page [Integer]
      # @param per [Integer]
      # @param title [String]
      # @param source [String]
      # @param definition_group [String]
      def definitions(page:, per:, title:, source:, definition_group:)
        definition_enumerator = DiverDown::Web::DefinitionEnumerator.new(@store, title:, source:, definition_group:)
        definitions, pagination = paginate(definition_enumerator, page, per)

        json(
          definitions: definitions.map do |definition|
            {
              id: definition.store_id,
              definition_group: definition.definition_group,
              title: definition.title,
              sources_count: definition.sources.size,
              unclassified_sources_count: definition.sources.reject { @module_store.include?(_1.source_name) }.size,
            }
          end,
          pagination: pagination.to_h
        )
      end

      # GET /api/initialization_status.json
      def initialization_status(total)
        json(
          total:,
          loaded: @store.size
        )
      end

      # GET /api/pid.json
      def pid
        json(
          pid: Process.pid
        )
      end

      # GET /api/definitions/:bit_id.json
      #
      # @param bit_id [Integer]
      # @param compound [Boolean]
      # @param concentrate [Boolean]
      # @param only_module [Boolean]
      def combine_definitions(bit_id, compound, concentrate, only_module)
        ids = DiverDown::Web::BitId.bit_id_to_ids(bit_id)

        valid_ids = ids.select do
          @store.key?(_1)
        end

        definition, titles = case valid_ids.length
                             when 0
                               return not_found
                             when 1
                               definition = @store.get(ids[0])
                               [definition, [definition.title]]
                             else
                               definitions = valid_ids.map { @store.get(_1) }
                               definition = DiverDown::Definition.combine(definition_group: nil, title: 'combined', definitions:)
                               [definition, definitions.map(&:title)]
                             end

        if definition
          definition_to_dot = DiverDown::Web::DefinitionToDot.new(definition, @module_store, compound:, concentrate:, only_module:)

          json(
            titles:,
            bit_id: DiverDown::Web::BitId.ids_to_bit_id(valid_ids).to_s,
            dot: definition_to_dot.to_s,
            dot_metadata: definition_to_dot.metadata,
            sources: definition.sources.map do
              {
                source_name: _1.source_name,
                modules: @module_store.get(_1.source_name).map do |module_name|
                  { module_name: }
                end,
              }
            end
          )
        else
          not_found
        end
      end

      # GET /api/sources/:source_name.json
      #
      # @param source_name [String]
      def source(source_name)
        found_sources = []
        related_definitions = []
        reverse_dependencies = Hash.new { |h, dependency_source_name| h[dependency_source_name] = DiverDown::Definition::Dependency.new(source_name: dependency_source_name) }

        @store.each do |id, definition|
          found_source = nil

          definition.sources.each do |definition_source|
            found_source = definition_source if definition_source.source_name == source_name

            found_reverse_dependencies = definition_source.dependencies.select do |dependency|
              dependency.source_name == source_name
            end

            found_reverse_dependencies.each do |dependency|
              reverse_dependency = reverse_dependencies[dependency.source_name]

              dependency.method_ids.each do |method_id|
                reverse_method_id = reverse_dependency.find_or_build_method_id(name: method_id.name, context: method_id.context)
                reverse_method_id.paths.merge(method_id.paths)
              end
            end
          end

          if found_source
            found_sources << found_source
            related_definitions << [id, definition]
          end
        end

        return not_found if related_definitions.empty?

        module_names = if found_sources.empty?
                         []
                       else
                         source = DiverDown::Definition::Source.combine(*found_sources)
                         @module_store.get(source.source_name)
                       end

        json(
          source_name:,
          modules: module_names.map do
            { module_name: _1 }
          end,
          related_definitions: related_definitions.map do |id, definition|
            {
              id:,
              title: definition.title,
            }
          end,
          reverse_dependencies: reverse_dependencies.values.map { |reverse_dependency|
            {
              source_name: reverse_dependency.source_name,
              method_ids: reverse_dependency.method_ids.sort.map do |method_id|
                {
                  context: method_id.context,
                  name: method_id.name,
                  paths: method_id.paths.sort,
                }
              end,
            }
          }
        )
      end

      # POST /api/sources/:source_name/modules.json
      #
      # @param source_name [String]
      # @param modules [Array<String>]
      def set_modules(source_name, modules)
        found_source = @store.any? do |_, definition|
          definition.sources.any? do |source|
            source.source_name == source_name
          end
        end

        if found_source
          @module_store.set(source_name, modules)
          @module_store.flush

          json({})
        else
          not_found
        end
      end

      # @return [Array[Integer, Hash, Array]]
      def not_found
        [404, { 'content-type' => 'text/plain' }, ['not found']]
      end

      private

      attr_reader :request, :store

      def build_method_id_key(dependency, method_id)
        "#{dependency.source_name}-#{method_id.context}-#{method_id.name}"
      end

      def paginate(enumerator, page, per)
        start_index = (page - 1) * per
        end_index = start_index + per - 1

        items = []
        enumerator.each_with_index do |item, index|
          next if index < start_index
          break if index > end_index

          items.push(item)
        end

        total_count = enumerator.size

        [
          items,
          Pagination.new(
            current_page: page,
            total_pages: [(total_count.to_f / per).ceil, 1].max,
            total_count:,
            per:
          ),
        ]
      end

      def fetch_definition(ids)
        case ids.length
        when 0
          nil
        when 1
          @store.get(ids[0])
        else
          combine_ids_definitions(ids)
        end
      end

      def json(data)
        [200, { 'content-type' => 'application/json' }, [data.to_json]]
      end
    end
  end
end
