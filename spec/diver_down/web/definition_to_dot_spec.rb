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

          instance = described_class.new(definition)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              "a.rb" [label="a.rb" id="graph_1"]
            }
          DOT

          expect(instance.metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'source',
                source_name: 'a.rb',
              },
            ]
          )
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
              {
                source_name: 'b.rb',
              },
            ]
          )

          instance = described_class.new(definition)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              "a.rb" [label="a.rb" id="graph_1"]
              "a.rb" -> "b.rb"
              "b.rb" [label="b.rb" id="graph_2"]
            }
          DOT

          expect(instance.metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'source',
                source_name: 'a.rb',
              }, {
                id: 'graph_2',
                type: 'source',
                source_name: 'b.rb',
              },
            ]
          )
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

          instance = described_class.new(definition)

          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              subgraph "cluster_A" {
                label="A" subgraph "cluster_B" {
                  label="B" "a.rb" [label="a.rb" id="graph_1"]
                }
              }
            }
          DOT

          expect(instance.metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'source',
                source_name: 'a.rb',
              },
            ]
          )
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

          instance = described_class.new(definition, compound: true)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              compound=true
              subgraph "cluster_A" {
                label="A" "a.rb" [label="a.rb" id="graph_1"]
              }
              "a.rb" -> "b.rb" [ltail="cluster_A" lhead="cluster_B" minlen="3"]
              subgraph "cluster_B" {
                label="B" "b.rb" [label="b.rb" id="graph_2"]
              }
              subgraph "cluster_B" {
                label="B" "c.rb" [label="c.rb" id="graph_3"]
              }
            }
          DOT

          expect(instance.metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'source',
                source_name: 'a.rb',
              }, {
                id: 'graph_2',
                type: 'source',
                source_name: 'b.rb',
              }, {
                id: 'graph_3',
                type: 'source',
                source_name: 'c.rb',
              },
            ]
          )
        end

        it 'returns concentrate digraph if concentrate = true' do
          definition = build_definition(
            sources: [
              {
                source_name: 'a.rb',
              },
            ]
          )

          instance = described_class.new(definition, concentrate: true)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              concentrate=true
              "a.rb" [label="a.rb" id="graph_1"]
            }
          DOT

          expect(instance.metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'source',
                source_name: 'a.rb',
              },
            ]
          )
        end
      end
    end
  end
end
