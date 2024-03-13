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
          stack = store.select(&:top?)

          while (definition = stack.shift)
            yield(definition)
            stack.unshift(*definition.children)
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

      # @param id [Array<String>]
      def combine_definitions(ids)
        valid_ids = ids.select do
          @store.key?(_1)
        end

        definition = fetch_definition(valid_ids)

        if definition
          json(
            id: definition.id,
            title: definition.title,
            dot: definition.to_dot
          )
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

      def fetch_definition(ids)
        case ids.length
        when 0
          nil
        when 1
          @store.get(ids[0])
        else
          @store.combined(ids)
        end
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
