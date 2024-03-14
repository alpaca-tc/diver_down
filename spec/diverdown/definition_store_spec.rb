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

    describe '#empty?' do
      it 'returns length == 0' do
        store = described_class.new
        expect(store.empty?).to be(true)

        definition = Diverdown::Definition.new
        store.set(definition)
        expect(store.empty?).to be(false)
      end
    end
  end
end
