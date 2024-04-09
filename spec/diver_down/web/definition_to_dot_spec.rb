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

      let(:module_store) do
        path = Tempfile.new(['test', '.yaml']).path
        DiverDown::Web::ModuleStore.new(path)
      end

      context 'when definition is blank' do
        it 'returns digraph' do
          definition = build_definition(
            title: 'title'
          )

          expect(described_class.new(definition, module_store).to_s).to eq(<<~DOT)
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

          instance = described_class.new(definition, module_store)
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

          instance = described_class.new(definition, module_store)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              "a.rb" [label="a.rb" id="graph_1"]
              "a.rb" -> "b.rb" [id="graph_2"]
              "b.rb" [label="b.rb" id="graph_3"]
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
                type: 'dependency',
                source_name: 'b.rb',
                method_ids: [],
              }, {
                id: 'graph_3',
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
              },
            ]
          )

          module_store.set('a.rb', ['A', 'B'])

          instance = described_class.new(definition, module_store)

          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              subgraph "cluster_A" {
                label="A" id="graph_1" subgraph "cluster_B" {
                  label="B" id="graph_2" "a.rb" [label="a.rb" id="graph_3"]
                }
              }
            }
          DOT

          expect(instance.metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'module',
                module_name: 'A',
              }, {
                id: 'graph_2',
                type: 'module',
                module_name: 'B',
              }, {
                id: 'graph_3',
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
                dependencies: [
                  {
                    source_name: 'b.rb',
                  }, {
                    source_name: 'c.rb',
                  },
                ],
              }, {
                source_name: 'b.rb',
              }, {
                source_name: 'c.rb',
              },
            ]
          )

          module_store.set('a.rb', ['A'])
          module_store.set('b.rb', ['B'])
          module_store.set('c.rb', ['B'])

          instance = described_class.new(definition, module_store, compound: true)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              compound=true
              subgraph "cluster_A" {
                label="A" id="graph_1" "a.rb" [label="a.rb" id="graph_2"]
              }
              "a.rb" -> "b.rb" [id="graph_3" ltail="cluster_A" lhead="cluster_B" minlen="3"]
              subgraph "cluster_B" {
                label="B" id="graph_5" "b.rb" [label="b.rb" id="graph_6"]
              }
              subgraph "cluster_B" {
                label="B" id="graph_7" "c.rb" [label="c.rb" id="graph_8"]
              }
            }
          DOT

          expect(instance.metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'module',
                module_name: 'A',
              }, {
                id: 'graph_2',
                type: 'source',
                source_name: 'a.rb',
              }, {
                id: 'graph_3',
                type: 'dependency',
                source_name: 'b.rb',
                method_ids: [],
              }, {
                id: 'graph_4',
                type: 'dependency',
                source_name: 'c.rb',
                method_ids: [],
              }, {
                id: 'graph_5',
                type: 'module',
                module_name: 'B',
              }, {
                id: 'graph_6',
                type: 'source',
                source_name: 'b.rb',
              }, {
                id: 'graph_7',
                type: 'module',
                module_name: 'B',
              }, {
                id: 'graph_8',
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

          instance = described_class.new(definition, module_store, concentrate: true)
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
