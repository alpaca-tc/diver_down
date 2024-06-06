# frozen_string_literal: true

RSpec.describe DiverDown::Web::Metadata::SourceAlias do
  describe 'InstanceMethods' do
    describe '#transaction' do
      it 'rolls back' do
        instance = described_class.new

        instance.update_alias('A', ['B'])
        expect(instance.to_h).to eq('A' => ['B'])

        error = described_class::ConflictError.new('error', source_name: 'A')
        expect {
          instance.transaction do
            instance.update_alias('A', ['C'])
            expect(instance.to_h).to eq('A' => ['C'])
            raise error
          end
        }.to raise_error(error)

        expect(instance.to_h).to eq('A' => ['B'])
      end
    end

    describe '#update_alias' do
      it 'adds/deletes alias' do
        instance = described_class.new

        instance.update_alias('A', ['B'])
        expect(instance.to_h).to eq('A' => ['B'])

        instance.update_alias('A', [])
        expect(instance.to_h).to eq({})
      end

      it 'combines source_names' do
        instance = described_class.new

        instance.update_alias('A', ['', ' '])
        expect(instance.to_h).to be_empty
      end

      it 'raises exception if source_names are conflicted with alias' do
        instance = described_class.new

        expect { instance.update_alias('A', ['A']) }.to raise_error(described_class::ConflictError)
      end

      it 'raises exception if source_name is already created alias' do
        instance = described_class.new
        instance.update_alias('A', ['B'])

        expect { instance.update_alias('C', ['B']) }.to raise_error(described_class::ConflictError)
      end

      it 'raises exception if alias is conflicted with source_names' do
        instance = described_class.new

        instance.update_alias('A', ['B'])
        expect { instance.update_alias('B', ['C']) }.to raise_error(described_class::ConflictError)
      end

      it 'raises exception if source_names are alias' do
        instance = described_class.new

        instance.update_alias('A', ['B'])
        expect { instance.update_alias('C', ['A']) }.to raise_error(described_class::ConflictError)
      end
    end

    describe '#resolve_alias' do
      it 'returns alias name or source_name' do
        instance = described_class.new

        instance.update_alias('A', ['B'])
        expect(instance.resolve_alias('A')).to be_nil
        expect(instance.resolve_alias('B')).to eq('A')
        expect(instance.resolve_alias('C')).to be_nil
      end
    end

    describe '#aliased_source_names' do
      it 'returns aliased source_names' do
        instance = described_class.new

        instance.update_alias('A', ['C', 'B'])
        expect(instance.aliased_source_names('A')).to eq(['B', 'C'])
        expect(instance.aliased_source_names('B')).to be_nil
      end
    end

    describe '#to_h' do
      it 'returns hash' do
        instance = described_class.new

        instance.update_alias('B', ['C'])
        instance.update_alias('A', ['D', 'E'].shuffle)

        expect(instance.to_h).to eq('A' => ['D', 'E'], 'B' => ['C'])
        expect(instance.to_h.keys).to eq(['A', 'B'])
      end
    end
  end
end
