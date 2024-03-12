# frozen_string_literal: true

RSpec.describe Diverdown::DefinitionStore do
  describe 'InstanceMethods' do
    describe '#get' do
      it 'raises KeyError if key not found' do
        store = described_class.new
        expect { store.get('unknown') }.to raise_error(KeyError)
      end

      it 'returns definition if key is found' do
        store = described_class.new
        definition = Diverdown::Definition.new
        store.set(definition)
        expect(store.get(definition.id)).to eq(definition)
      end
    end

    describe '#key?' do
      it 'raises KeyError if key not found' do
        store = described_class.new
        expect(store.key?('unknown')).to be(false)
      end

      it 'returns definition if key is found' do
        store = described_class.new
        definition = Diverdown::Definition.new
        store.set(definition)
        expect(store.key?(definition.id)).to be(true)
      end
    end

    describe '#combined' do
      it 'returns combined definition' do
        store = described_class.new
        definition_a = Diverdown::Definition.new(
          id: '1',
          sources: [
            Diverdown::Definition::Source.new(
              source: 'a.rb'
            ),
          ]
        )

        definition_b = Diverdown::Definition.new(
          id: '2',
          sources: [
            Diverdown::Definition::Source.new(
              source: 'b.rb'
            ),
          ]
        )

        store.set(definition_a, definition_b)

        combined_definition = store.combined([definition_a.id, definition_b.id])
        expect(combined_definition.id).to eq('1_2')
        expect(combined_definition.sources.size).to eq(2)
        expect(combined_definition.sources.map(&:source).sort).to eq(['a.rb', 'b.rb'])
      end
    end

    describe '#clear' do
      it 'clears store' do
        store = described_class.new
        definition = Diverdown::Definition.new
        store.set(definition)
        expect(store.length).to eq(1)
        store.clear
        expect(store.length).to eq(0)
      end
    end
  end
end
