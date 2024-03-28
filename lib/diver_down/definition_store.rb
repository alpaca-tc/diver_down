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
      index = id - 1

      raise(KeyError, "id not found: #{id}") if id <= 0 || @definitions.size < id

      @definitions.fetch(index)
    end

    # @param definitions [Array<Diverdown::Definition>]
    # @return [Array<Integer>] ids of the definitions
    def set(*definitions)
      definitions.map do
        raise ArgumentError, "Definition already set #{_1.to_h}" if @invert_id.key?(_1)

        id = @definitions.size + 1
        @definitions.push(_1)
        @invert_id[_1] = id
        @definition_group_store[_1.definition_group] << _1

        id
      end
    end

    # @return [Array<String, nil>]
    def definition_groups
      keys = @definition_group_store.keys
      with_nil = keys.include?(nil)
      keys.delete(nil) if with_nil

      keys.sort!
      keys.push(nil) if with_nil
      keys
    end

    # @param definition_group [String, nil]
    # @return [Array<Diverdown::Definition>]
    def filter_by_definition_group(definition_group)
      @definition_group_store.fetch(definition_group, [])
    end

    # @param definition [Diverdown::Definition]
    # @raise [KeyError] if the definition is not found
    # @return [Integer]
    def get_id(definition)
      @invert_id.fetch(definition)
    end

    # @param id [Integer]
    # @return [Boolean]
    def key?(id)
      id.positive? && id <= @definitions.size
    end

    # @return [Integer]
    def length
      @definitions.length
    end
    alias size length

    # @return [Boolean]
    def empty?
      @definitions.empty?
    end

    # Clear the store
    # @return [void]
    def clear
      # Hash{ Integer(unique bit flag) => Diverdown::Definition }
      @definitions = []
      @invert_id = {}
      @definition_group_store = Hash.new { |h, k| h[k] = [] }
    end

    # @yield [Diverdown::Definition]
    def each
      return enum_for(__method__) unless block_given?

      # NOTE: To allow values to be rewritten during #each, duplicate the value through #to_a.
      @definitions.each.with_index(1) do |definition, id|
        yield(id, definition)
      end
    end
  end
end
