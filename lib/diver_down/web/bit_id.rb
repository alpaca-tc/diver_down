# frozen_string_literal: true

module DiverDown
  class Web
    # Use bitflag for a lightweight representation of a list of bound definitions on a URL.
    # Each definition is related with a unique bitflag, and when merging, the bitflag is calculated with `OR` to represent the merged definitions in a lightweight and fast.
    module BitId
      class << self
        # @param ids [Array<Integer>]
        # @return [Integer]
        def ids_to_bit_id(ids)
          ids.inject(0) { _1 | id_to_bit_id(_2) }
        end

        # @param id [Integer]
        # @return [Array<Integer>]
        def bit_id_to_ids(bit_id)
          ids = []
          shift = 0
          while bit_id.positive?
            if bit_id & 1
              ids.push(shift + 1)
            end

            bit_id >>= 1
            shift += 1
          end
          ids
        end

        private

        # @param id [Integer]
        # @return [Integer]
        def id_to_bit_id(id)
          1 << (id - 1)
        end
      end
    end
  end
end
