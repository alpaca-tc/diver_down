# frozen_string_literal: true

module Diverdown
  class Definition
    # Use bitflag for a lightweight representation of a list of bound definitions on a URL hash.
    # Each definition is related with a unique bitflag, and when merging, the bitflag is calculated with `OR` to represent the merged definitions in a lightweight and fast.
    class BitId
      def initialize
        @shift = 0
      end

      # @return [Integer] unique bit flag id
      def next_id
        val = 1 << @shift
        @shift += 1
        val
      end

      # @param id [Integer]
      # @return [Array<Integer>]
      def separate_bit_id(id)
        ids = []
        shift = 0
        while id.positive?
          ids << (id & 1 << shift)
          id &= ~(1 << shift)
          shift += 1
        end
        ids
      end
    end
  end
end
