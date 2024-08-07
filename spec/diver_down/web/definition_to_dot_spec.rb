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

      let(:metadata) do
        path = Tempfile.new(['test', '.yaml']).path
        DiverDown::Web::Metadata.new(path)
      end

      context 'when definition is blank' do
        it 'returns digraph' do
          definition = build_definition(
            title: 'title'
          )

          expect(described_class.new(definition, metadata).to_s).to eq(<<~DOT)
            strict digraph "title" {
            }
          DOT
        end
      end

      context 'when definition title contains double-quote' do
        it 'returns escaped title' do
          definition = build_definition(
            title: '"title"'
          )

          expect(described_class.new(definition, metadata).to_s).to eq(<<~DOT)
            strict digraph "\\"title\\"" {
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
                memo: '',
              },
            ]
          )

          metadata.source('a.rb').memo = 'memo'

          instance = described_class.new(definition, metadata)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              "a.rb" [label="a.rb" id="graph_1"]
            }
          DOT

          expect(instance.dot_metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'source',
                source_name: 'a.rb',
                memo: 'memo',
                module: nil,
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
                memo: '',
                dependencies: [
                  {
                    source_name: 'b.rb',
                  },
                ],
              },
              {
                source_name: 'b.rb',
                memo: '',
              },
            ]
          )

          instance = described_class.new(definition, metadata)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              "a.rb" [label="a.rb" id="graph_1"]
              "b.rb" [label="b.rb" id="graph_2"]
              "a.rb" -> "b.rb" [id="graph_3" minlen="3"]
            }
          DOT

          expect(instance.dot_metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'source',
                source_name: 'a.rb',
                memo: '',
                module: nil,
              }, {
                id: 'graph_2',
                type: 'source',
                source_name: 'b.rb',
                memo: '',
                module: nil,
              }, {
                id: 'graph_3',
                type: 'dependency',
                dependencies: [
                  {
                    source_name: 'b.rb',
                    method_ids: [],
                  },
                ],
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

          metadata.source('a.rb').module = 'A'

          instance = described_class.new(definition, metadata)

          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              subgraph "cluster_A" {
                id="graph_1"
                label="A"
                "a.rb" [label="a.rb" id="graph_2"]
              }
            }
          DOT

          expect(instance.dot_metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'module',
                module: 'A',
              }, {
                id: 'graph_2',
                type: 'source',
                source_name: 'a.rb',
                memo: '',
                module: 'A',
              },
            ]
          )
        end

        it 'returns digraph given multiple modules' do
          definition = build_definition(
            sources: [
              {
                source_name: 'a.rb',
                dependencies: [
                  {
                    source_name: 'b.rb',
                    method_ids: [
                      {
                        name: 'call_b',
                        context: 'class',
                        paths: [],
                      },
                    ],
                  }, {
                    source_name: 'c.rb',
                    method_ids: [
                      {
                        name: 'call_c',
                        context: 'class',
                        paths: [],
                      },
                    ],
                  }, {
                    source_name: 'd.rb',
                    method_ids: [
                      {
                        name: 'call_d',
                        context: 'class',
                        paths: [],
                      },
                    ],
                  },
                ],
              }, {
                source_name: 'b.rb',
              }, {
                source_name: 'c.rb',
              }, {
                source_name: 'd.rb',
              },
            ]
          )

          metadata.source('a.rb').module = 'A'
          metadata.source('b.rb').module = 'B'
          metadata.source('c.rb').module = 'B'
          metadata.source('d.rb').module = nil
          metadata.source('unknown.rb').module = 'Unknown'

          instance = described_class.new(definition, metadata)

          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              "d.rb" [label="d.rb" id="graph_1"]
              subgraph "cluster_A" {
                id="graph_2"
                label="A"
                "a.rb" [label="a.rb" id="graph_3"]
              }
              subgraph "cluster_B" {
                id="graph_4"
                label="B"
                "b.rb" [label="b.rb" id="graph_5"]
                "c.rb" [label="c.rb" id="graph_6"]
              }
              "a.rb" -> "b.rb" [id="graph_7" minlen="3"]
              "a.rb" -> "c.rb" [id="graph_8" minlen="3"]
              "a.rb" -> "d.rb" [id="graph_9" minlen="3"]
            }
          DOT
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

          metadata.source('a.rb').module = 'A'
          metadata.source('b.rb').module = 'B'
          metadata.source('c.rb').module = 'B'

          instance = described_class.new(definition, metadata, compound: true)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              compound=true
              subgraph "cluster_A" {
                id="graph_1"
                label="A"
                "a.rb" [label="a.rb" id="graph_2"]
              }
              subgraph "cluster_B" {
                id="graph_3"
                label="B"
                "b.rb" [label="b.rb" id="graph_4"]
                "c.rb" [label="c.rb" id="graph_5"]
              }
              "a.rb" -> "b.rb" [id="graph_6" ltail="cluster_A" lhead="cluster_B" minlen="3"]
            }
          DOT

          expect(instance.dot_metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'module',
                module: 'A',
              }, {
                id: 'graph_2',
                type: 'source',
                source_name: 'a.rb',
                memo: '',
                module: 'A',
              }, {
                id: 'graph_3',
                type: 'module',
                module: 'B',
              }, {
                id: 'graph_4',
                type: 'source',
                source_name: 'b.rb',
                memo: '',
                module: 'B',
              }, {
                id: 'graph_5',
                type: 'source',
                source_name: 'c.rb',
                memo: '',
                module: 'B',
              }, {
                id: 'graph_6',
                type: 'dependency',
                dependencies: [
                  {
                    source_name: 'b.rb',
                    method_ids: [],
                  }, {
                    source_name: 'c.rb',
                    method_ids: [],
                  },
                ],
              },
            ]
          )
        end

        it 'returns compound digraph with multiple method_ids if compound = true' do
          definition = build_definition(
            sources: [
              {
                source_name: 'a.rb',
                dependencies: [
                  {
                    source_name: 'b.rb',
                    method_ids: [
                      {
                        name: 'call_b',
                        context: 'class',
                        paths: [],
                      },
                    ],
                  }, {
                    source_name: 'c.rb',
                    method_ids: [
                      {
                        name: 'call_c',
                        context: 'class',
                        paths: [],
                      },
                    ],
                  },
                ],
              }, {
                source_name: 'b.rb',
              }, {
                source_name: 'c.rb',
              },
            ]
          )

          metadata.source('a.rb').module = 'A'
          metadata.source('b.rb').module = 'B'
          metadata.source('c.rb').module = 'B'

          instance = described_class.new(definition, metadata, compound: true)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              compound=true
              subgraph "cluster_A" {
                id="graph_1"
                label="A"
                "a.rb" [label="a.rb" id="graph_2"]
              }
              subgraph "cluster_B" {
                id="graph_3"
                label="B"
                "b.rb" [label="b.rb" id="graph_4"]
                "c.rb" [label="c.rb" id="graph_5"]
              }
              "a.rb" -> "b.rb" [id="graph_6" ltail="cluster_A" lhead="cluster_B" minlen="3"]
            }
          DOT

          expect(instance.dot_metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'module',
                module: 'A',
              }, {
                id: 'graph_2',
                type: 'source',
                source_name: 'a.rb',
                memo: '',
                module: 'A',
              }, {
                id: 'graph_3',
                type: 'module',
                module: 'B',
              }, {
                id: 'graph_4',
                type: 'source',
                source_name: 'b.rb',
                memo: '',
                module: 'B',
              }, {
                id: 'graph_5',
                type: 'source',
                source_name: 'c.rb',
                memo: '',
                module: 'B',
              }, {
                id: 'graph_6',
                type: 'dependency',
                dependencies: [
                  {
                    source_name: 'b.rb',
                    method_ids: [
                      {
                        name: 'call_b',
                        context: 'class',
                      },
                    ],
                  }, {
                    source_name: 'c.rb',
                    method_ids: [
                      {
                        name: 'call_c',
                        context: 'class',
                      },
                    ],
                  },
                ],
              },
            ]
          )
        end

        it 'returns compound module digraph with multiple method_ids if only_module = true' do
          definition = build_definition(
            sources: [
              {
                source_name: 'a.rb',
                dependencies: [
                  {
                    source_name: 'b.rb',
                    method_ids: [
                      {
                        name: 'call_b',
                        context: 'class',
                        paths: [],
                      },
                    ],
                  }, {
                    source_name: 'c.rb',
                    method_ids: [
                      {
                        name: 'call_c',
                        context: 'class',
                        paths: [],
                      },
                    ],
                  },
                ],
              }, {
                source_name: 'b.rb',
              }, {
                source_name: 'c.rb',
              },
            ]
          )

          metadata.source('a.rb').module = 'A'
          metadata.source('b.rb').module = 'B'
          metadata.source('c.rb').module = 'B'
          metadata.source('unknown.rb').module = 'Unknown'

          instance = described_class.new(definition, metadata, only_module: true)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              compound=true
              subgraph "cluster_A" {
                id="graph_1"
                label="A"
                "A" [label="A" id="graph_1"]
              }
              subgraph "cluster_B" {
                id="graph_2"
                label="B"
                "B" [label="B" id="graph_2"]
              }
              "A" -> "B" [id="graph_3" ltail="cluster_A" lhead="cluster_B" minlen="3"]
            }
          DOT

          expect(instance.dot_metadata).to eq(
            [
              { id: 'graph_1', type: 'module', module: 'A' },
              { id: 'graph_2', type: 'module', module: 'B' },
              {
                id: 'graph_3',
                type: 'dependency',
                dependencies: [
                  {
                    source_name: 'b.rb',
                    method_ids: [
                      { name: 'call_b', context: 'class' },
                    ],
                  }, {
                    source_name: 'c.rb',
                    method_ids: [
                      { name: 'call_c', context: 'class' },
                    ],
                  },
                ],
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

          instance = described_class.new(definition, metadata, concentrate: true)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              concentrate=true
              "a.rb" [label="a.rb" id="graph_1"]
            }
          DOT

          expect(instance.dot_metadata).to eq(
            [
              {
                id: 'graph_1',
                type: 'source',
                source_name: 'a.rb',
                memo: '',
                module: nil,
              },
            ]
          )
        end

        it 'returns concentrate digraph with multiple modules if concentrate = true' do
          definition = build_definition(
            sources: [
              {
                source_name: 'a.rb',
              },
              {
                source_name: 'b.rb',
              },
              {
                source_name: 'c.rb',
              },
              {
                source_name: 'd.rb',
              },
            ]
          )

          metadata.source('b.rb').module = 'A'
          metadata.source('c.rb').module = 'C'
          metadata.source('d.rb').module = 'B'

          instance = described_class.new(definition, metadata, concentrate: true)
          expect(instance.to_s).to eq(<<~DOT)
            strict digraph "title" {
              concentrate=true
              "a.rb" [label="a.rb" id="graph_1"]
              subgraph "cluster_A" {
                id="graph_2"
                label="A"
                "b.rb" [label="b.rb" id="graph_3"]
              }
              subgraph "cluster_B" {
                id="graph_4"
                label="B"
                "d.rb" [label="d.rb" id="graph_5"]
              }
              subgraph "cluster_C" {
                id="graph_6"
                label="C"
                "c.rb" [label="c.rb" id="graph_7"]
              }
            }
          DOT

          expect(instance.dot_metadata).to eq(
            [
              { id: 'graph_1', type: 'source', source_name: 'a.rb', memo: '', module: nil },
              { id: 'graph_2', type: 'module', module: 'A' },
              { id: 'graph_3', type: 'source', source_name: 'b.rb', memo: '', module: 'A' },
              { id: 'graph_4', type: 'module', module: 'B' },
              { id: 'graph_5', type: 'source', source_name: 'd.rb', memo: '', module: 'B' },
              { id: 'graph_6', type: 'module', module: 'C' },
              { id: 'graph_7', type: 'source', source_name: 'c.rb', memo: '', module: 'C' },
            ]
          )
        end
      end
    end
  end
end
