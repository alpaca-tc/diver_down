# frozen_string_literal: true

RSpec.describe DiverDown::Web::DefinitionToDot do
  describe 'InstanceMethods' do
    describe '#to_s' do
      def build_definition(title: 'title', sources: [])
        definition_sources = sources.map do |source|
          dependencies = (source[:dependencies] || []).map do |dependency|
            DiverDown::Definition::Dependency.new(**dependency)
          end

          modules = (source[:modules] || []).map do |mod|
            DiverDown::Definition::Modulee.new(**mod)
          end

          DiverDown::Definition::Source.new(**source, dependencies:, modules:)
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
      end
    end
  end
end
