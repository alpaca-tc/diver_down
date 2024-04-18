# frozen_string_literal: true

RSpec.describe DiverDown::Web::DefinitionEnumerator do
  describe 'InstanceMethods' do
    describe '#each' do
      it 'returns definitions sorted by definition_group' do
        store = DiverDown::Web::DefinitionStore.new
        definition_1 = DiverDown::Definition.new
        definition_2 = DiverDown::Definition.new(definition_group: 'b', title: 'definition_2')
        definition_3 = DiverDown::Definition.new(definition_group: 'c', title: 'definition_3')
        definition_4 = DiverDown::Definition.new(definition_group: 'c', title: 'definition_4')
        store.set(definition_1, definition_2, definition_3, definition_4)

        expect(described_class.new(store).each.to_a).to eq(
          [
            # definition_group b
            definition_2,

            # definition_group c
            definition_3,
            definition_4,

            # definition_group nil
            definition_1,
          ]
        )
      end

      describe 'with definition_group' do
        def assert_query(store, definition_group, expected)
          actual = described_class.new(store, definition_group:).each.to_a
          expect(actual).to eq(expected), -> {
            "definition_group: #{definition_group.inspect}\n" \
            "expected: #{expected.inspect}\n" \
            "actual: #{actual.inspect}"
          }
        end

        it 'filters by definition_group' do
          store = DiverDown::Web::DefinitionStore.new

          definition_1 = DiverDown::Definition.new(
            definition_group: 'group_1',
            sources: [
              DiverDown::Definition::Source.new(
                source_name: 'a.rb'
              ),
            ]
          )
          definition_2 = DiverDown::Definition.new(
            definition_group: 'group_2',
            sources: [
              DiverDown::Definition::Source.new(
                source_name: 'b.rb'
              ),
            ]
          )

          store.set(definition_1, definition_2)

          assert_query store, 'unknown', []
          assert_query store, 'group', [definition_1, definition_2]
          assert_query store, 'group_1', [definition_1]
          assert_query store, 'group_2', [definition_2]
        end
      end

      describe 'with title' do
        def assert_query(store, title, expected)
          actual = described_class.new(store, title:).each.to_a
          expect(actual).to eq(expected), -> {
            "title: #{title.inspect}\n" \
            "expected: #{expected.inspect}\n" \
            "actual: #{actual.inspect}"
          }
        end

        it 'filters by title' do
          store = DiverDown::Web::DefinitionStore.new

          definition_1 = DiverDown::Definition.new(
            title: '01234',
            sources: [
              DiverDown::Definition::Source.new(
                source_name: 'a.rb'
              ),
            ]
          )
          definition_2 = DiverDown::Definition.new(
            title: '56789',
            sources: [
              DiverDown::Definition::Source.new(
                source_name: 'b.rb'
              ),
            ]
          )

          store.set(definition_1, definition_2)

          assert_query store, 'unknown', []

          # Strict match
          assert_query store, '01234', [definition_1]
          assert_query store, '56789', [definition_2]
          assert_query store, 'a.rb', []

          # like match
          assert_query store, '0', [definition_1]
          assert_query store, '7', [definition_2]
          assert_query store, 'a', []
        end
      end

      describe 'with source' do
        def assert_query(store, source, expected)
          actual = described_class.new(store, source:).each.to_a
          expect(actual).to eq(expected), -> {
            "source: #{source.inspect}\n" \
            "expected: #{expected.inspect}\n" \
            "actual: #{actual.inspect}"
          }
        end

        it 'filters by source' do
          store = DiverDown::Web::DefinitionStore.new

          definition_1 = DiverDown::Definition.new(
            title: '01234',
            sources: [
              DiverDown::Definition::Source.new(
                source_name: 'a.rb'
              ),
            ]
          )
          definition_2 = DiverDown::Definition.new(
            title: '56789',
            sources: [
              DiverDown::Definition::Source.new(
                source_name: 'b.rb'
              ),
            ]
          )

          store.set(definition_1, definition_2)

          assert_query store, 'unknown', []

          # Strict match
          assert_query store, '01234', []
          assert_query store, '56789', []
          assert_query store, 'a.rb', [definition_1]
          assert_query store, 'b.rb', [definition_2]

          # like match
          assert_query store, '0', []
          assert_query store, 'a', [definition_1]
          assert_query store, 'b.', [definition_2]
        end
      end
    end
  end
end
