# frozen_string_literal: true

RSpec.describe Diverdown::Definition::BitId do
  describe 'InstanceMethods' do
    describe '#next_id' do
      def count_ones(int)
        int.to_s(2).count('1')
      end

      # Length of the int for test
      let(:n) do
        1000
      end

      it 'returns unique bit flag id' do
        bit_id = described_class.new
        ids = Array.new(n) { bit_id.next_id }
        expect(ids.length).to eq(ids.uniq.length)
      end

      it 'returns bit flag' do
        bit_id = described_class.new
        ids = Array.new(n) { bit_id.next_id }
        expect(ids).to all(satisfy { count_ones(_1) == 1 })

        int_or = ids.inject(0, :|)
        expect(count_ones(int_or)).to eq(n)
      end
    end

    describe '#separate_bit_id' do
      it 'separates given id to each bit' do
        bit_id = described_class.new
        ids = Array.new(10) { bit_id.next_id }
        int_or = ids.inject(0, :|)
        expect(bit_id.separate_bit_id(int_or)).to eq(ids)
      end
    end
  end
end
