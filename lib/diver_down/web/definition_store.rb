# frozen_string_literal: true

module DiverDown
  class DefinitionStore
    include Enumerable

    attr_reader :bit_id

    def initialize
      # Hash{ Integer(unique bit flag) => DiverDown::Definition }
      @definitions = []
      @definition_group_store = Hash.new { |h, k| h[k] = [] }
    end

    # @param id [Integer]
    # @raise [KeyError] if the id is not found
    # @return [DiverDown::Definition]
    def get(id)
      index = id - 1

      raise(KeyError, "id not found: #{id}") if id <= 0 || @definitions.size < id

      @definitions.fetch(index)
    end

    # @param definitions [Array<DiverDown::Definition>]
    # @return [Array<Integer>] ids of the definitions
    def set(*definitions)
      definitions.map do
        raise(ArgumentError, 'definition already set') if _1.store_id

        _1.store_id = @definitions.size + 1

        @definitions.push(_1)
        @definition_group_store[_1.definition_group] << _1

        _1.store_id
      end
    end

    # @return [Array<String, nil>]
    def definition_groups
      keys = @definition_group_store.keys

      # Sort keys with nil at the end
      with_nil = keys.include?(nil)
      keys.delete(nil) if with_nil
      keys.sort!
      keys.push(nil) if with_nil

      keys
    end

    # @param definition_group [String, nil]
    # @return [Array<DiverDown::Definition>]
    def filter_by_definition_group(definition_group)
      @definition_group_store.fetch(definition_group, [])
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

    # @yield [DiverDown::Definition]
    def each
      return enum_for(__method__) unless block_given?

      # NOTE: To allow values to be rewritten during #each, duplicate the value through #to_a.
      @definitions.each.with_index(1) do |definition, id|
        yield(id, definition)
      end
    end
  end
end
