# frozen_string_literal: true

RSpec.describe Diverdown::Web::DefinitionEnumerator do
  describe 'InstanceMethods' do
    describe '#each' do
      it 'returns digraph' do
        store = Diverdown::DefinitionStore.new
        definition_1 = Diverdown::Definition.new
        definition_2 = Diverdown::Definition.new(definition_group: 'b', title: 'definition_2')
        definition_3 = Diverdown::Definition.new(definition_group: 'c', title: 'definition_3')
        definition_4 = Diverdown::Definition.new(definition_group: 'c', title: 'definition_4')
        store.set(definition_1, definition_2, definition_3, definition_4)

        expect(described_class.new(store).each.to_a).to eq(
          [
            # definition_group b
            described_class::Row.new(type: 'definition_group', definition_group: 'b', label: 'b', bit_id: nil),
            described_class::Row.new(type: 'definition', definition_group: 'b', label: definition_2.title, bit_id: store.get_id(definition_2)),

            # definition_group c
            described_class::Row.new(type: 'definition_group', definition_group: 'c', label: 'c', bit_id: nil),
            described_class::Row.new(type: 'definition', definition_group: 'c', label: definition_3.title, bit_id: store.get_id(definition_3)),
            described_class::Row.new(type: 'definition', definition_group: 'c', label: definition_4.title, bit_id: store.get_id(definition_4)),

            # definition_group nil
            described_class::Row.new(type: 'definition', definition_group: nil, label: definition_1.title, bit_id: store.get_id(definition_1)),
          ]
        )
      end

      it 'ignores blank definition_group' do
        store = Diverdown::DefinitionStore.new
        definition = Diverdown::Definition.new(
          definition_group: nil
        )
        store.set(definition)

        expect(described_class.new(store).each.to_a).to eq(
          [
            described_class::Row.new(type: 'definition', definition_group: nil, label: definition.title, bit_id: store.get_id(definition)),
          ]
        )
      end
    end

    describe '#length' do
      it 'returns size of definitions + size of definition_group - nil definition_group' do
        store = Diverdown::DefinitionStore.new
        definition_1 = Diverdown::Definition.new
        definition_2 = Diverdown::Definition.new(definition_group: 'b', title: 'definition_2')
        definition_3 = Diverdown::Definition.new(definition_group: 'c', title: 'definition_3')
        definition_4 = Diverdown::Definition.new(definition_group: 'c', title: 'definition_4')
        store.set(definition_1, definition_2, definition_3, definition_4)

        expect(described_class.new(store).length).to eq(6)
      end
    end
  end
end
