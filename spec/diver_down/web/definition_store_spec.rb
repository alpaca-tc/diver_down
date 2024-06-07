# frozen_string_literal: true

RSpec.describe DiverDown::Web::DefinitionStore do
  describe 'InstanceMethods' do
    describe '#get' do
      it 'raises KeyError if key not found' do
        store = described_class.new
        definition = DiverDown::Definition.new
        store.set(definition)

        expect { store.get(0) }.to raise_error(KeyError)
        expect { store.get(2) }.to raise_error(KeyError)
      end

      it 'returns definition if key is found' do
        store = described_class.new
        definition = DiverDown::Definition.new
        ids = store.set(definition)
        expect(store.get(ids[0])).to eq(definition)
      end
    end

    describe '#set' do
      it 'set definitions' do
        store = described_class.new
        definition_1 = DiverDown::Definition.new(title: 'a')
        definition_2 = DiverDown::Definition.new(title: 'b')
        definition_3 = DiverDown::Definition.new(title: 'c')
        ids = store.set(definition_1, definition_2, definition_3)
        expect(ids).to eq([1, 2, 3])
        expect([definition_1, definition_2, definition_3]).to all(be_frozen)
      end

      it 'returns id if definition already set' do
        store = described_class.new
        definition = DiverDown::Definition.new(title: 'a')
        store.set(definition)

        expect { store.set(definition) }.to raise_error(ArgumentError, 'definition already set')
      end
    end

    describe '#combined_definition' do
      it 'returns combined_definition' do
        store = described_class.new
        definition_1 = DiverDown::Definition.new(title: 'a')
        definition_2 = DiverDown::Definition.new(title: 'b')
        definition_3 = DiverDown::Definition.new(title: 'c')
        store.set(definition_1, definition_2, definition_3)

        expect(store.combined_definition).to be_a(DiverDown::Definition)
      end
    end

    describe '#definition_groups' do
      it 'returns definition_groups' do
        store = described_class.new
        definition_1 = DiverDown::Definition.new
        definition_2 = DiverDown::Definition.new(definition_group: 'b')
        definition_3 = DiverDown::Definition.new(definition_group: 'c', title: '1')
        definition_4 = DiverDown::Definition.new(definition_group: 'c', title: '2')
        store.set(definition_1, definition_2, definition_3, definition_4)

        expect(store.definition_groups).to eq(['b', 'c', nil])
      end
    end

    describe '#filter_by_definition_group' do
      it 'returns definitions' do
        store = described_class.new
        definition_1 = DiverDown::Definition.new
        definition_2 = DiverDown::Definition.new(definition_group: 'b')
        definition_3 = DiverDown::Definition.new(definition_group: 'c', title: '1')
        definition_4 = DiverDown::Definition.new(definition_group: 'c', title: '2')
        store.set(definition_1, definition_2, definition_3, definition_4)

        expect(store.filter_by_definition_group(nil)).to eq([definition_1])
        expect(store.filter_by_definition_group('b')).to eq([definition_2])
        expect(store.filter_by_definition_group('c')).to eq([definition_3, definition_4])
      end
    end

    describe '#key?' do
      it 'raises KeyError if key not found' do
        store = described_class.new
        expect(store.key?(0)).to be(false)
      end

      it 'returns definition if key is found' do
        store = described_class.new
        definition = DiverDown::Definition.new
        ids = store.set(definition)
        expect(store.key?(ids[0])).to be(true)
      end
    end

    describe '#empty?' do
      it 'returns length == 0' do
        store = described_class.new
        expect(store.empty?).to be(true)

        definition = DiverDown::Definition.new
        store.set(definition)
        expect(store.empty?).to be(false)
      end
    end
  end
end
