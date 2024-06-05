# frozen_string_literal: true

RSpec.describe DiverDown::Web::Metadata::SourceAlias do
  describe 'InstanceMethods' do
    describe '#resolve_alias' do
      it 'returns alias name or source_name' do
        instance = described_class.new

        instance.add_alias('A', ['A', 'B'])
        expect(instance.resolve_alias('A')).to eq('A')
        expect(instance.resolve_alias('B')).to eq('A')
        expect(instance.resolve_alias('C')).to eq('C')
      end
    end

    describe '#aliased_source_names' do
      it 'returns aliased source_names' do
        instance = described_class.new

        instance.add_alias('A', ['A', 'C', 'B'])
        expect(instance.aliased_source_names('A')).to eq(['A', 'B', 'C'])
        expect(instance.aliased_source_names('B')).to be_nil
      end
    end

    describe '#to_h' do
      it 'returns hash' do
        instance = described_class.new

        instance.add_alias('B', ['C'])
        instance.add_alias('A', ['A', 'B', 'C'].shuffle)

        expect(instance.to_h).to eq('A' => ['A', 'B', 'C'], 'B' => ['C'])
        expect(instance.to_h.keys).to eq(['A', 'B'])
      end
    end
  end
end
