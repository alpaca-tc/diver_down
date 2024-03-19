# frozen_string_literal: true

module Diverdown
  class DefinitionStore
    include Enumerable

    attr_reader :bit_id

    def initialize
      clear
    end

    # @param id [Integer]
    # @raise [KeyError] if the id is not found
    # @return [Diverdown::Definition]
    def get(id)
      @store.fetch(id)
    end

    # @param definitions [Array<Diverdown::Definition>]
    # @return [Array<Integer>] ids of the definitions
    def set(*definitions)
      definitions.map do
        id = @bit_id.next_id
        @store[id] = _1
        @invert_store[_1] = id
        @definition_group_store[_1.definition_group] << _1
        id
      end
    end

    # @param definition_group [String, nil]
    # @return [Array<Diverdown::Definition>]
    def filter_by_definition_group(definition_group)
      @definition_group_store.fetch(definition_group, [])
    end

    # @param definition [Diverdown::Definition]
    # @raise [KeyError] if the definition is not found
    # @return [Integer]
    def get_bit_id(definition)
      @invert_store.fetch(definition)
    end

    # @param id [Integer]
    # @return [Boolean]
    def key?(id)
      @store.key?(id)
    end

    # @return [Integer]
    def length
      @store.length
    end
    alias size length

    # @return [Boolean]
    def empty?
      @store.empty?
    end

    # Clear the store
    # @return [void]
    def clear
      # Hash{ Integer(unique bit flag) => Diverdown::Definition }
      @store = {}
      @invert_store = {}
      @bit_id = Diverdown::Definition::BitId.new
      @definition_group_store = Hash.new { |h,k| h[k] = [] }
    end

    # @yield [Diverdown::Definition]
    def each
      # NOTE: To allow values to be rewritten during #each, duplicate the value through #to_a.
      @store.to_a.each do |(id, definition)|
        yield(id, definition)
      end
    end
  end
end
