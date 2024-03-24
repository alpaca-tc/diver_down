# frozen_string_literal: true

module Diverdown
  class Web
    class DefinitionEnumerator
      include Enumerable

      # @param store [Diverdown::Definition::Store]
      # @param query [String]
      def initialize(store, query: '')
        @store = store
        @query = query
      end

      # @yield [parent_bit_id, bit_id, definition]
      def each
        return enum_for(__method__) unless block_given?

        definition_groups = @store.definition_groups
        definition_groups.each do |definition_group|
          definitions = @store.filter_by_definition_group(definition_group)
          definitions.each do
            next unless match_definition?(_1)

            id = @store.get_id(_1)
            yield(id, _1)
          end
        end
      end

      # @return [Integer]
      def size
        @store.size
      end
      alias length size

      private

      def match_definition?(definition)
        return true if @query.empty?

        definition.title.include?(@query) ||
          definition.sources.any? { _1.source_name.include?(@query) }
      end
    end
  end
end
