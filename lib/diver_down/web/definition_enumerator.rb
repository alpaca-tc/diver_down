# frozen_string_literal: true

module DiverDown
  class Web
    class DefinitionEnumerator
      include Enumerable

      # @param store [DiverDown::Definition::Store]
      # @param query [String]
      # @param definition_group [String]
      def initialize(store, title: '', source: '', definition_group: '')
        @store = store
        @title = title
        @source = source
        @definition_group = definition_group
      end

      # @yield [parent_bit_id, bit_id, definition]
      def each
        return enum_for(__method__) unless block_given?

        definition_groups = @store.definition_groups
        definition_groups.each do |definition_group|
          definitions = @store.filter_by_definition_group(definition_group)
          definitions.each do
            next unless match_definition?(_1)

            yield(_1)
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
        matched = true

        unless @title.empty?
          matched &&= definition.title.include?(@title)
        end

        unless @source.empty?
          matched &&= definition.sources.any? { _1.source_name.include?(@source) }
        end

        unless @definition_group.empty?
          matched &&= definition.definition_group.to_s.include?(@definition_group)
        end

        matched
      end
    end
  end
end
