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

      M = Mutex.new

      attr_reader :store

      # @param store [DiverDown::Definition::Store]
      # @param metadata [DiverDown::Web::Metadata]
      def initialize(store:, metadata:)
        @store = store
        @metadata = metadata
        @source_alias_resolver = DiverDown::Web::SourceAliasResolver.new(@metadata.source_alias)
        @module_dependency_map = nil
        @module_dependency_map_cache_id = nil
      end

      # GET /api/source_aliases.json
      def source_aliases
        source_aliases = @metadata.source_alias.to_h.map do |alias_name, source_names|
          {
            alias_name:,
            source_names:,
          }
        end

        json(
          source_aliases:
        )
      end

      # POST /api/source_aliases.json
      # @param alias_name [String]
      # @param old_alias_name [String]
      # @param source_names [Array<String>]
      def update_source_alias(alias_name, old_alias_name, source_names)
        @metadata.source_alias.transaction do
          unless old_alias_name.to_s.empty?
            # Delete old alias
            @metadata.source_alias.update_alias(old_alias_name, [])
          end

          @metadata.source_alias.update_alias(alias_name, source_names)
        end

        @metadata.flush

        json({})
      rescue DiverDown::Web::Metadata::SourceAlias::ConflictError => e
        json_error(e.message)
      end

      # GET /api/sources.json
      def sources
        source_names = Set.new

        @store.combined_definition.sources.each do |source|
          source_names.add(source.source_name)
        end

        classified_sources_count = source_names.count { @metadata.source(_1).module? }

        json(
          sources: source_names.sort.map do |source_name|
            source_metadata = @metadata.source(source_name)

            {
              source_name:,
              resolved_alias: @metadata.source_alias.resolve_alias(source_name),
              memo: source_metadata.memo,
              module: source_metadata.module,
            }
          end,
          classified_sources_count:
        )
      end

      # GET /api/modules.json
      def modules
        # Hash{ DiverDown::Definition::Modulee => Set<Integer> }
        modules = Set.new

        @store.combined_definition.sources.each do |source|
          modulee = @metadata.source(source.source_name).module
          modules.add(modulee) unless modulee.nil?
        end

        json(
          modules: modules.sort
        )
      end

      # GET /api/modules/:modulee.json
      # @param modulee [String]
      def module(modulee)
        module_dependency_map = fetch_module_dependency_map

        unless module_dependency_map.key?(modulee)
          return not_found
        end

        module_dependency = module_dependency_map.fetch(modulee)

        json(
          module: modulee,
          module_dependencies: module_dependency.module_dependencies.compact.sort,
          module_reverse_dependencies: module_dependency.module_reverse_dependencies.compact.sort,
          sources: module_dependency.sources.map do |source|
            {
              source_name: source.source_name,
              module: @metadata.source(source.source_name).module,
              memo: @metadata.source(source.source_name).memo,
              dependencies: source.dependencies.map do |dependency|
                {
                  source_name: dependency.source_name,
                  module: @metadata.source(dependency.source_name).module,
                  method_ids: dependency.method_ids.sort.map do |method_id|
                    {
                      context: method_id.context,
                      name: method_id.name,
                      paths: method_id.paths.sort,
                    }
                  end,
                }
              end,
            }
          end,
          source_reverse_dependencies: module_dependency.source_reverse_dependencies.map do |source|
            {
              source_name: source.source_name,
              module: @metadata.source(source.source_name).module,
              memo: @metadata.source(source.source_name).memo,
              dependencies: source.dependencies.map do |dependency|
                {
                  source_name: dependency.source_name,
                  module: @metadata.source(dependency.source_name).module,
                  method_ids: dependency.method_ids.sort.map do |method_id|
                    {
                      context: method_id.context,
                      name: method_id.name,
                      paths: method_id.paths.sort,
                    }
                  end,
                }
              end,
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
              unclassified_sources_count: definition.sources.reject { @metadata.source(_1.source_name).module? }.size,
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

      # GET /api/global_definition.json
      #
      # @param bit_id [Integer]
      # @param compound [Boolean]
      # @param concentrate [Boolean]
      # @param only_module [Boolean]
      # @param modules [Array<String>]
      def global_definition(compound, concentrate, only_module, remove_internal_sources, focus_modules, modules)
        definition = @store.combined_definition

        # Resolve source aliases
        resolved_definition = @source_alias_resolver.resolve(definition)
        # Filter sources and dependencies by condition
        resolved_definition = DiverDown::Web::DefinitionFilter.new(@metadata, focus_modules:, modules:, remove_internal_sources:).filter(resolved_definition)

        render_combined_definition(
          (1..@store.size).to_a,
          resolved_definition,
          modules,
          compound:,
          concentrate:,
          only_module:
        )
      end

      # GET /api/definitions/:bit_id.json
      #
      # @param bit_id [Integer]
      # @param compound [Boolean]
      # @param concentrate [Boolean]
      # @param only_module [Boolean]
      def combine_definitions(bit_id, compound, concentrate, only_module, remove_internal_sources, focus_modules, modules)
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
          # Resolve source aliases
          resolved_definition = @source_alias_resolver.resolve(definition)
          # Filter sources and dependencies by condition
          resolved_definition = DiverDown::Web::DefinitionFilter.new(@metadata, focus_modules:, modules:, remove_internal_sources:).filter(resolved_definition)

          render_combined_definition(
            valid_ids,
            resolved_definition,
            titles,
            compound:,
            concentrate:,
            only_module:
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

        modulee = if found_sources.empty?
                    nil
                  else
                    source = DiverDown::Definition::Source.combine(*found_sources)
                    @metadata.source(source.source_name).module
                  end

        json(
          source_name:,
          resolved_alias: @metadata.source_alias.resolve_alias(source_name),
          memo: @metadata.source(source_name).memo,
          module: modulee,
          related_definitions: related_definitions.map do |id, definition|
            {
              id:,
              title: definition.title,
            }
          end,
          reverse_dependencies: reverse_dependencies.values.map { |reverse_dependency|
            {
              source_name: reverse_dependency.source_name,
              module: @metadata.source(reverse_dependency.source_name).module,
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

      # POST /api/sources/:source_name/module.json
      #
      # @param source_name [String]
      # @param module [Array<String>]
      def set_module(source_name, modulee)
        found_source = @store.any? do |_, definition|
          definition.sources.any? do |source|
            source.source_name == source_name
          end
        end

        if found_source
          @metadata.source(source_name).module = modulee
          @metadata.flush

          json({})
        else
          not_found
        end
      end

      # POST /api/sources/:source_name/memo.json
      #
      # @param source_name [String]
      # @param memo [String]
      def set_memo(source_name, memo)
        found_source = @store.any? do |_, definition|
          definition.sources.any? do |source|
            source.source_name == source_name
          end
        end

        if found_source
          @metadata.source(source_name).memo = memo
          @metadata.flush

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

      def json(data, status = 200)
        [status, { 'content-type' => 'application/json' }, [data.to_json]]
      end

      def json_error(message, status = 422)
        json({ message: }, status)
      end

      def render_combined_definition(ids, definition, titles, compound:, concentrate:, only_module:)
        definition_to_dot = DiverDown::Web::DefinitionToDot.new(definition, @metadata, compound:, concentrate:, only_module:)

        json(
          titles:,
          bit_id: DiverDown::Web::BitId.ids_to_bit_id(ids).to_s,
          dot: definition_to_dot.to_s,
          dot_metadata: definition_to_dot.dot_metadata,
          sources: definition.sources.map do
            {
              source_name: _1.source_name,
              resolved_alias: @metadata.source_alias.resolve_alias(_1.source_name),
              memo: @metadata.source(_1.source_name).memo,
              module: @metadata.source(_1.source_name).module,
              dependencies: _1.dependencies.map do |dependency|
                {
                  source_name: dependency.source_name,
                }
              end,
            }
          end
        )
      end

      def fetch_module_dependency_map
        M.synchronize do
          if @module_dependency_map_cache_id != @store.combined_definition.object_id
            definition = @store.combined_definition
            @module_dependency_map = DiverDown::Web::DefinitionModuleDependencies.new(@metadata, definition).build_module_dependency_map
            @module_dependency_map_cache_id = definition.object_id
          end
        end

        @module_dependency_map
      end
    end
  end
end
