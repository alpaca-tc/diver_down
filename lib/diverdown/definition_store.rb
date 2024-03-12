# frozen_string_literal: true

module Diverdown
  class DefinitionStore
    include Enumerable

    def initialize
      # Hash{ String => Diverdown::Definition }
      @store = {}
    end

    # @param id [String]
    # @raise [idError] if the id is not found
    # @return [Diverdown::Definition]
    def get(id)
      @store.fetch(id)
    end

    # @param definitions [Array<Diverdown::Definition>]
    # @return [void]
    def set(*definitions)
      definitions.each do
        @store[_1.id] = _1
      end
    end

    # @param id [String]
    # @return [Boolean]
    def key?(id)
      @store.key?(id)
    end

    # @return [Integer]
    def length
      @store.length
    end
    alias size length

    # Clear the store
    # @return [void]
    def clear
      @store.clear
    end

    # @yield [Diverdown::Definition]
    def each
      # rubocop:disable Style/HashEachMethods
      @store.values.each do
        yield(_1)
      end
      # rubocop:enable Style/HashEachMethods
    end

    # Combine multiple definitions into a single definition
    # @param ids [Array<String>]
    # @return [Diverdown::Definition]
    def combined(ids)
      raise ArgumentError, 'ids must be an non-blank array' if ids.empty?

      definitions = ids.map { get(_1) }

      definitions.inject(Diverdown::Definition.new(id: ids.sort.join(','), title: 'combined')) do |single_definition, other_definition|
        single_definition.combine(other_definition)
      end
    end
  end
end
