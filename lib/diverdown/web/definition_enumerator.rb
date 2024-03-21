# frozen_string_literal: true

module Diverdown
  class Web
    class DefinitionEnumerator
      include Enumerable

      Row = Data.define(:type, :definition_group, :label, :bit_id)

      # @param store [Diverdown::Definition::Store]
      def initialize(store)
        @store = store
      end

      # @yield [parent_bit_id, bit_id, definition]
      def each
        return enum_for(__method__) unless block_given?

        definition_groups = @store.definition_groups
        definition_groups.each do |definition_group|
          unless definition_group.nil?
            yield(
              Row.new(
                type: 'definition_group',
                definition_group:,
                label: definition_group,
                bit_id: nil
              )
            )
          end

          definitions = @store.filter_by_definition_group(definition_group)
          definitions.each do |definition|
            row = Row.new(
              type: 'definition',
              definition_group:,
              label: definition.title,
              bit_id: @store.get_id(definition)
            )

            yield(row)
          end
        end
      end

      # @return [Integer] size of definitions + size of definition_group
      def length
        @store.length + @store.definition_groups.reject(&:nil?).size
      end
      alias size length
    end
  end
end
