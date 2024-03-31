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
      # @param request [Rack::Request]
      def initialize(store:, request:)
        @store = store
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

        json(
          sources: source_names.sort.map do |source_name|
            {
              source_name:,
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
      def definitions(page:, per:, title:, source:)
        definition_enumerator = DiverDown::Web::DefinitionEnumerator.new(@store, title:, source:)
        definitions, pagination = paginate(definition_enumerator, page, per)

        json(
          definitions: definitions.map do |definition|
            {
              id: definition.store_id,
              definition_group: definition.definition_group,
              title: definition.title,
            }
          end,
          pagination: pagination.to_h
        )
      end

      # GET /api/definitions/:bit_id.json
      #
      # @param bit_id [Integer]
      def combine_definitions(bit_id)
        ids = DiverDown::Web::BitId.bit_id_to_ids(bit_id)

        valid_ids = ids.select do
          @store.key?(_1)
        end

        definition = fetch_definition(valid_ids)

        if definition
          json(
            bit_id: DiverDown::Web::BitId.ids_to_bit_id(valid_ids).to_s,
            title: definition.title,
            dot: DiverDown::Web::DefinitionToDot.new(definition).to_s,
            sources: definition.sources.map { { source_name: _1.source_name } }
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

        modules = if found_sources.empty?
                    []
                  else
                    DiverDown::Definition::Source.combine(*found_sources).modules
                  end

        json(
          source_name:,
          modules: modules.map(&:to_h),
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

      def combine_ids_definitions(ids)
        definitions = ids.map { @store.get(_1) }
        DiverDown::Definition.combine(definition_group: nil, title: 'combined', definitions:)
      end

      def json(data)
        [200, { 'content-type' => 'application/json' }, [data.to_json]]
      end
    end
  end
end
