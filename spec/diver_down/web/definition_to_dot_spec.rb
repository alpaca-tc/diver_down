# frozen_string_literal: true

RSpec.describe DiverDown::Web::DefinitionToDot do
  describe 'InstanceMethods' do
    describe '#to_s' do
      def build_definition(title: 'title', sources: [])
        definition_sources = sources.map do |source|
          DiverDown::Definition::Source.from_hash(source)
        end

        DiverDown::Definition.new(title:, sources: definition_sources)
      end

      context 'when definition is blank' do
        it 'returns digraph' do
          definition = build_definition(
            title: 'title'
          )

          expect(described_class.new(definition).to_s).to eq(<<~DOT)
            strict digraph "title" {
            }
          DOT
        end
      end

      context 'with single source' do
        it 'returns digraph' do
          definition = build_definition(
            sources: [
              {
                source_name: 'a.rb',
              },
            ]
          )

          expect(described_class.new(definition).to_s).to eq(<<~DOT)
            strict digraph "title" {
              "a.rb" [label="a.rb"]
            }
          DOT
        end
      end

      context 'with dependencies' do
        it 'returns digraph' do
          definition = build_definition(
            sources: [
              {
                source_name: 'a.rb',
                dependencies: [
                  {
                    source_name: 'b.rb',
                  },
                ],
              },
            ]
          )

          expect(described_class.new(definition).to_s).to eq(<<~DOT)
            strict digraph "title" {
              "a.rb" [label="a.rb"]
              "a.rb" -> "b.rb"
            }
          DOT
        end
      end

      context 'with module' do
        it 'returns digraph' do
          definition = build_definition(
            sources: [
              {
                source_name: 'a.rb',
                modules: [
                  {
                    module_name: 'A',
                  }, {
                    module_name: 'B',
                  },
                ],
              },
            ]
          )

          expect(described_class.new(definition).to_s).to eq(<<~DOT)
            strict digraph "title" {
              subgraph "cluster_A" {
                label="A" subgraph "cluster_B" {
                  label="B" "a.rb" [label="a.rb"]
                }
              }
            }
          DOT
        end

        it 'returns compound digraph if compound = true' do
          definition = build_definition(
            sources: [
              {
                source_name: 'a.rb',
                modules: [
                  {
                    module_name: 'A',
                  },
                ],
                dependencies: [
                  {
                    source_name: 'b.rb',
                  }, {
                    source_name: 'c.rb',
                  },
                ],
              }, {
                source_name: 'b.rb',
                modules: [
                  {
                    module_name: 'B',
                  },
                ],
                dependencies: [],
              }, {
                source_name: 'c.rb',
                modules: [
                  {
                    module_name: 'B',
                  },
                ],
                dependencies: [],
              },
            ]
          )

          expect(described_class.new(definition, compound: true).to_s).to eq(<<~DOT)
            strict digraph "title" {
              compound=true
              subgraph "cluster_A" {
                label="A" "a.rb" [label="a.rb"]
              }
              "a.rb" -> "b.rb" [ltail="cluster_A" lhead="cluster_B"]
              "a.rb" -> "c.rb" [ltail="cluster_A" lhead="cluster_B"]
              subgraph "cluster_B" {
                label="B" "b.rb" [label="b.rb"]
              }
              subgraph "cluster_B" {
                label="B" "c.rb" [label="c.rb"]
              }
            }
          DOT
        end

        it 'returns concentrate digraph if concentrate = true' do
          definition = build_definition(
            sources: [
              {
                source_name: 'a.rb',
              },
            ]
          )

          expect(described_class.new(definition, concentrate: true).to_s).to eq(<<~DOT)
            strict digraph "title" {
              concentrate=true
              "a.rb" [label="a.rb"]
            }
          DOT
        end
      end
    end
  end
end
