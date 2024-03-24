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

      describe 'with query' do
        def assert_query(store, query, expected)
          actual = described_class.new(store, query:).each.map { _2 }
          expect(actual).to eq(expected), -> {
            "query: #{query.inspect}\n" \
            "expected: #{expected.inspect}\n" \
            "actual: #{actual.inspect}"
          }
        end

        it 'filters by query' do
          store = Diverdown::DefinitionStore.new

          definition_1 = Diverdown::Definition.new(
            title: '01234',
            sources: [
              Diverdown::Definition::Source.new(
                source_name: 'a.rb'
              ),
            ]
          )
          definition_2 = Diverdown::Definition.new(
            title: '56789',
            sources: [
              Diverdown::Definition::Source.new(
                source_name: 'b.rb'
              ),
            ]
          )

          store.set(definition_1, definition_2)

          assert_query store, 'unknown', []

          # Strict match
          assert_query store, '01234', [definition_1]
          assert_query store, '56789', [definition_2]
          assert_query store, 'a.rb', [definition_1]
          assert_query store, 'b.rb', [definition_2]

          # like match
          assert_query store, '0', [definition_1]
          assert_query store, '1', [definition_1]
          assert_query store, '4', [definition_1]
          assert_query store, 'a', [definition_1]
          assert_query store, 'b.', [definition_2]
        end
      end
    end
  end
end
