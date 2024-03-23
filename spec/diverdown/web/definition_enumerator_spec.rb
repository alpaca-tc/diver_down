# frozen_string_literal: true

RSpec.describe Diverdown::Web::DefinitionEnumerator do
  describe 'InstanceMethods' do
    describe '#each' do
      it 'returns definitions sorted by definition_group' do
        store = Diverdown::DefinitionStore.new
        definition_1 = Diverdown::Definition.new
        definition_2 = Diverdown::Definition.new(definition_group: 'b', title: 'definition_2')
        definition_3 = Diverdown::Definition.new(definition_group: 'c', title: 'definition_3')
        definition_4 = Diverdown::Definition.new(definition_group: 'c', title: 'definition_4')
        ids = store.set(definition_1, definition_2, definition_3, definition_4)

        expect(described_class.new(store).each.to_a).to eq(
          [
            # definition_group b
            [ids[1], definition_2],

            # definition_group c
            [ids[2], definition_3],
            [ids[3], definition_4],

            # definition_group nil
            [ids[0], definition_1],
          ]
        )
      end
    end
  end
end
