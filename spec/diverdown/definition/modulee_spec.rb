# frozen_string_literal: true

RSpec.describe Diverdown::Definition::Modulee do
  describe 'InstanceMethods' do
    describe '#hash' do
      it 'returns a hash' do
        modulee = described_class.new(name: 'A')

        expect(modulee.hash).to eq(modulee.dup.hash)
      end
    end

    describe '#<=>' do
      it 'compares with other' do
        array = [
          Diverdown::Definition::Modulee.new(
            name: 'a'
          ),
          Diverdown::Definition::Modulee.new(
            name: 'b'
          ),
          Diverdown::Definition::Modulee.new(
            name: 'c'
          ),
        ].shuffle

        expect(array.sort.map(&:name)).to eq(%w[a b c])
      end
    end

    describe '#==' do
      it 'compares with other' do
        modulee = described_class.new(name: 'A')

        expect(modulee).to eq(described_class.new(name: 'A'))
        expect(modulee).to_not eq(described_class.new(name: 'B'))
        expect(modulee).to_not eq(Object.new)
      end
    end

    describe '#to_h' do
      it 'returns a hash' do
        modulee = Diverdown::Definition::Modulee.new(
          name: 'A'
        )

        expect(modulee.to_h).to eq(
          name: 'A'
        )
      end
    end
  end
end
