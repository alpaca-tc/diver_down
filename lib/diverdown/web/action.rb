# frozen_string_literal: true

require 'json'

module Diverdown
  class Web
    class Action
      IMPORTMAP_JSON = File.join(WEB_DIR, 'importmap.json')
      private_constant :IMPORTMAP_JSON

      module Helpers
        # @param path [String]
        # @return [String]
        def asset_path(path)
          File.join(WEB_DIR, 'assets', path)
        end

        # @return [String]
        def javascript_importmap_tags
          <<~EOS
            <script type="importmap">
              #{File.read(IMPORTMAP_JSON)}
            </script>
          EOS
        end

        # @param store [Diverdown::Definition::Store]
        # @yield [Diverdown::Definition]
        # @return [Enumerator]
        def each_definition(store)
          Diverdown::Web::DefinitionEnumerator.new(store).each do
            yield(_1)
          end
        end
      end

      private_constant :Helpers

      # @param store [Diverdown::Definition::Store]
      # @param request [Rack::Request]
      def initialize(store:, request:)
        @store = store
        @request = request
      end

      # @return [Array[Integer, Hash, Array]]
      def index
        body = erb(:index, locals: { store: @store })
        [200, { 'content-type' => 'text/html' }, [body]]
      end

      # @param bit_id [Integer]
      def combine_definitions(bit_id)
        ids = @store.bit_id.separate_bit_id(bit_id)

        valid_ids = ids.select do
          @store.key?(_1)
        end

        definition = fetch_definition(valid_ids)

        if definition
          json(
            bit_id: valid_ids.inject(0, :|),
            title: definition.title,
            dot: Diverdown::Web::DefinitionToDot.new(definition).to_s,
            sources: definition.sources.map { { source_name: _1.source_name } }
          )
        else
          not_found
        end
      end

      # @param source_name [String]
      def source(source_name)
        found_sources = []
        related_definitions = []
        reverse_dependencies = Hash.new { |h, k| h[k] = Set.new }

        @store.each do |bit_id, definition|
          found_source = nil

          definition.sources.each do |definition_source|
            found_source = definition_source if definition_source.source_name == source_name

            dependencies = definition_source.dependencies.select do |dependency|
              dependency.source_name == source_name
            end

            method_ids = dependencies.flat_map(&:method_ids).uniq.sort

            method_ids.each do |method_id|
              reverse_dependencies[definition_source.source_name].add(method_id)
            end
          end

          if found_source
            found_sources << found_source
            related_definitions << [bit_id, definition]
          end
        end

        modules = Diverdown::Definition::Source.combine(*found_sources).modules

        if related_definitions.empty?
          not_found
        else
          body = erb(:source, locals: { source_name:, modules:, related_definitions:, reverse_dependencies: })
          [200, { 'content-type' => 'text/html' }, [body]]
        end
      end

      # @return [Array[Integer, Hash, Array]]
      def not_found
        [404, { 'content-type' => 'text/plain' }, ['not found']]
      end

      private

      attr_reader :request, :store

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
        Diverdown::Definition.combine(title: 'combined', definitions:)
      end

      def view_path(path)
        File.join(WEB_DIR, path)
      end

      def json(data)
        [200, { 'content-type' => 'application/json' }, [data.to_json]]
      end

      def erb(template, locals: { _: nil })
        path = view_path("#{template}.erb")
        content = File.read(path)

        isolated_environment = Data.define(*locals.keys) do
          include Helpers
        end.new(**locals)

        b = isolated_environment.instance_eval { binding }
        ERB.new(content).result(b)
      end
    end
  end
end
