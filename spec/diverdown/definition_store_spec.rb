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
        ids = store.set(definition)
        expect(store.get(ids[0])).to eq(definition)
      end
    end

    describe '#filter_by_definition_group' do
      it 'returns definitions' do
        store = described_class.new
        definition_1 = Diverdown::Definition.new
        definition_2 = Diverdown::Definition.new(definition_group: 'b')
        definition_3 = Diverdown::Definition.new(definition_group: 'c')
        definition_4 = Diverdown::Definition.new(definition_group: 'c')
        store.set(definition_1, definition_2, definition_3, definition_4)

        expect(store.filter_by_definition_group(nil)).to eq([definition_1])
        expect(store.filter_by_definition_group('b')).to eq([definition_2])
        expect(store.filter_by_definition_group('c')).to eq([definition_3, definition_4])
      end
    end

    describe '#get_bit_id' do
      it 'raises KeyError if key not found' do
        store = described_class.new
        expect { store.get(Diverdown::Definition.new) }.to raise_error(KeyError)
      end

      it 'returns bit_id if definition is found' do
        store = described_class.new
        definition = Diverdown::Definition.new
        ids = store.set(definition)
        expect(store.get_bit_id(definition)).to eq(ids[0])
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
        ids = store.set(definition)
        expect(store.key?(ids[0])).to be(true)
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
