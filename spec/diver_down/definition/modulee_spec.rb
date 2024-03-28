# frozen_string_literal: true

RSpec.describe DiverDown::Definition::Modulee do
  describe 'InstanceMethods' do
    describe '#hash' do
      it 'returns a hash' do
        modulee = described_class.new(module_name: 'A')

        expect(modulee.hash).to eq(modulee.dup.hash)
      end
    end

    describe '#<=>' do
      it 'compares with other' do
        array = [
          DiverDown::Definition::Modulee.new(
            module_name: 'a'
          ),
          DiverDown::Definition::Modulee.new(
            module_name: 'b'
          ),
          DiverDown::Definition::Modulee.new(
            module_name: 'c'
          ),
        ].shuffle

        expect(array.sort.map(&:module_name)).to eq(%w[a b c])
      end
    end

    describe '#==' do
      it 'compares with other' do
        modulee = described_class.new(module_name: 'A')

        expect(modulee).to eq(described_class.new(module_name: 'A'))
        expect(modulee).to_not eq(described_class.new(module_name: 'B'))
        expect(modulee).to_not eq(Object.new)
      end
    end

    describe '#to_h' do
      it 'returns a hash' do
        modulee = DiverDown::Definition::Modulee.new(
          module_name: 'A'
        )

        expect(modulee.to_h).to eq(
          module_name: 'A'
        )
      end
    end
  end
end
