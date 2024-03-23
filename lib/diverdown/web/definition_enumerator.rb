# frozen_string_literal: true

module Diverdown
  class Web
    class DefinitionEnumerator
      include Enumerable

      # @param store [Diverdown::Definition::Store]
      def initialize(store)
        @store = store
      end

      # @yield [parent_bit_id, bit_id, definition]
      def each
        return enum_for(__method__) unless block_given?

        definition_groups = @store.definition_groups
        definition_groups.each do |definition_group|
          definitions = @store.filter_by_definition_group(definition_group)
          definitions.each do
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
    end
  end
end
