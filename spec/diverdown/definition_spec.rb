# frozen_string_literal: true

RSpec.describe Diverdown::Definition do
  describe 'ClassMethods' do
    describe '.from_hash' do
      it 'loads hash' do
        definition = described_class.new(
          title: 'title',
          package: 'x/y/z',
          sources: [
            Diverdown::Definition::Source.new(
              source_name: 'a.rb',
              dependencies: [
                Diverdown::Definition::Dependency.new(
                  source_name: 'b.rb'
                ),
                Diverdown::Definition::Dependency.new(
                  source_name: 'c.rb'
                ),
              ],
              modules: [
                Diverdown::Definition::Modulee.new(
                  module_name: 'A'
                ),
              ]
            ),
          ]
        )

        expect(described_class.from_hash(definition.to_h)).to eq(definition)
      end
    end

    describe '.combine' do
      it 'combines definitions' do
        definition_1 = described_class.new(
          title: 'title',
          sources: [
            Diverdown::Definition::Source.new(
              source_name: 'a.rb',
              dependencies: [
                Diverdown::Definition::Dependency.new(
                  source_name: 'b.rb'
                ),
                Diverdown::Definition::Dependency.new(
                  source_name: 'c.rb'
                ),
              ],
              modules: [
                Diverdown::Definition::Modulee.new(
                  module_name: 'A'
                ),
              ]
            ),
          ]
        )

        definition_2 = described_class.new(
          title: 'title',
          sources: [
            Diverdown::Definition::Source.new(
              source_name: 'd.rb',
              dependencies: [
                Diverdown::Definition::Dependency.new(
                  source_name: 'e.rb'
                ),
                Diverdown::Definition::Dependency.new(
                  source_name: 'f.rb'
                ),
              ],
              modules: [
                Diverdown::Definition::Modulee.new(
                  module_name: 'B'
                ),
              ]
            ),
          ]
        )

        definition = described_class.combine(title: '2', definitions: [definition_1, definition_2])

        expect(definition.sources.length).to eq(2)
        expect(definition.sources[0].source_name).to eq('a.rb')
        expect(definition.sources[1].source_name).to eq('d.rb')
      end
    end
  end

  describe 'InstanceMethods' do
    describe '#find_or_build_source' do
      it 'finds or builds source' do
        definition = described_class.new
        expect(definition.sources.length).to eq(0)

        source_1 = definition.find_or_build_source('a.rb')
        expect(definition.sources.length).to eq(1)

        source_2 = definition.find_or_build_source('a.rb')
        expect(definition.sources.length).to eq(1)
        expect(source_1).to eq(source_2)

        definition.find_or_build_source('b.rb')
        expect(definition.sources.length).to eq(2)
      end
    end

    describe '#source' do
      it 'finds source by source name' do
        definition = described_class.new
        expect(definition.source('a.rb')).to be_nil

        source_1 = definition.find_or_build_source('a.rb')
        expect(definition.source(source_1.source_name)).to eq(source_1)
      end
    end

    describe '#top?' do
      it "set parent and add self to parent's children" do
        parent = described_class.new
        child = described_class.new

        child.parent = parent

        expect(parent.top?).to be(true)
        expect(child.top?).to be(false)
      end
    end

    describe '#level' do
      it 'returns nested level' do
        parent = described_class.new
        child = described_class.new
        nested_child = described_class.new

        child.parent = parent
        nested_child.parent = child

        expect(parent.level).to eq(0)
        expect(child.level).to eq(1)
        expect(nested_child.level).to eq(2)
      end
    end

    describe '#parent=' do
      it "set parent and add self to parent's children" do
        parent = described_class.new
        child = described_class.new

        child.parent = parent

        expect(child.parent).to eq(parent)
        expect(parent.children).to include(child)
      end
    end

    describe '#to_h' do
      it 'converts definition to hash' do
        definition = described_class.new(
          title: 'title',
          package: 'x/y/z',
          sources: [
            Diverdown::Definition::Source.new(
              source_name: 'a.rb',
              dependencies: [
                Diverdown::Definition::Dependency.new(
                  source_name: 'b.rb',
                  method_ids: [
                    Diverdown::Definition::MethodId.new(
                      name: 'A',
                      context: 'class',
                      paths: ['a.rb']
                    ),
                  ]
                ),
                Diverdown::Definition::Dependency.new(
                  source_name: 'c.rb'
                ),
              ],
              modules: [
                Diverdown::Definition::Modulee.new(
                  module_name: 'A'
                ),
              ]
            ),
          ]
        )

        expect(definition.to_h).to eq(
          title: definition.title,
          package: definition.package,
          sources: [
            {
              source_name: 'a.rb',
              dependencies: [
                {
                  source_name: 'b.rb',
                  method_ids: [
                    {
                      name: 'A',
                      context: 'class',
                      paths: ['a.rb'],
                    },
                  ],
                }, {
                  source_name: 'c.rb',
                  method_ids: [],
                },
              ],
              modules: [
                {
                  module_name: 'A',
                },
              ],
            },
          ]
        )
      end
    end
  end
end
