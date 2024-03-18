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
        id
      end
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
      @bit_id = Diverdown::Definition::BitId.new
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
