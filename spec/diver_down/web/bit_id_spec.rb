# frozen_string_literal: true

RSpec.describe DiverDown::Web::BitId do
  describe 'ClassMethods' do
    describe '.ids_to_bit_id' do
      it 'returns bit_id' do
        expect(described_class.ids_to_bit_id([1])).to eq(1)
        expect(described_class.ids_to_bit_id([2])).to eq(2)
        expect(described_class.ids_to_bit_id([3])).to eq(4)
        expect(described_class.ids_to_bit_id([4])).to eq(8)

        expect(described_class.ids_to_bit_id([])).to eq(0)
        expect(described_class.ids_to_bit_id([1, 4])).to eq(9)
        expect(described_class.ids_to_bit_id([1, 2, 3, 4])).to eq(15)
      end
    end

    describe '.bit_id_to_ids' do
      it 'converts given bit_id to each id' do
        ids = (1..100).to_a
        bit_ids = ids.map { described_class.ids_to_bit_id([_1]) }
        int_or = bit_ids.inject(0, :|)

        expect(described_class.bit_id_to_ids(int_or)).to eq(ids)
      end
    end
  end
end
