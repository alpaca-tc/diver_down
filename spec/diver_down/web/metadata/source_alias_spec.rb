# frozen_string_literal: true

RSpec.describe DiverDown::Web::Metadata::SourceAlias do
  describe 'InstanceMethods' do
    describe '#update_alias' do
      it 'adds/deletes alias' do
        instance = described_class.new

        instance.update_alias('A', ['A', 'B'])
        expect(instance.to_h).to eq('A' => ['A', 'B'])

        instance.update_alias('A', [])
        expect(instance.to_h).to eq({})
      end

      it 'combines source_names' do
        instance = described_class.new

        instance.update_alias('A', ['', ' '])
        expect(instance.to_h).to be_empty
      end

      it 'raises exception if source_names are conflicted' do
        instance = described_class.new

        instance.update_alias('A', ['A', 'B'])
        expect { instance.update_alias('B', ['A']) }.to raise_error(described_class::ConflictError)
      end
    end

    describe '#resolve_alias' do
      it 'returns alias name or source_name' do
        instance = described_class.new

        instance.update_alias('A', ['A', 'B'])
        expect(instance.resolve_alias('A')).to eq('A')
        expect(instance.resolve_alias('B')).to eq('A')
        expect(instance.resolve_alias('C')).to be_nil
      end
    end

    describe '#aliased_source_names' do
      it 'returns aliased source_names' do
        instance = described_class.new

        instance.update_alias('A', ['A', 'C', 'B'])
        expect(instance.aliased_source_names('A')).to eq(['A', 'B', 'C'])
        expect(instance.aliased_source_names('B')).to be_nil
      end
    end

    describe '#to_h' do
      it 'returns hash' do
        instance = described_class.new

        instance.update_alias('B', ['C'])
        instance.update_alias('A', ['A', 'B'].shuffle)

        expect(instance.to_h).to eq('A' => ['A', 'B'], 'B' => ['C'])
        expect(instance.to_h.keys).to eq(['A', 'B'])
      end
    end
  end
end
