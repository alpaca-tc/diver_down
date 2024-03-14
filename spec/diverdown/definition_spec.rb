# frozen_string_literal: true

RSpec.describe Diverdown::Definition do
  describe 'ClassMethods' do
    describe '.from_hash' do
      it 'loads hash' do
        definition = described_class.new(
          title: 'title',
          sources: [
            Diverdown::Definition::Source.new(
              source: 'a.rb',
              dependencies: [
                Diverdown::Definition::Dependency.new(
                  source: 'b.rb'
                ),
                Diverdown::Definition::Dependency.new(
                  source: 'c.rb'
                ),
              ],
              modules: [
                Diverdown::Definition::Modulee.new(
                  name: 'A'
                ),
              ]
            ),
          ]
        )

        expect(described_class.from_hash(definition.to_h)).to eq(definition)
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
        expect(definition.source(source_1.source)).to eq(source_1)
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
          sources: [
            Diverdown::Definition::Source.new(
              source: 'a.rb',
              dependencies: [
                Diverdown::Definition::Dependency.new(
                  source: 'b.rb',
                  method_ids: [
                    Diverdown::Definition::MethodId.new(
                      name: 'A',
                      context: 'class',
                      paths: ['a.rb']
                    ),
                  ]
                ),
                Diverdown::Definition::Dependency.new(
                  source: 'c.rb'
                ),
              ],
              modules: [
                Diverdown::Definition::Modulee.new(
                  name: 'A'
                ),
              ]
            ),
          ]
        )

        expect(definition.to_h).to eq(
          id: definition.id,
          title: definition.title,
          sources: [
            {
              source: 'a.rb',
              dependencies: [
                {
                  source: 'b.rb',
                  method_ids: [
                    {
                      name: 'A',
                      context: 'class',
                      paths: ['a.rb'],
                    },
                  ],
                }, {
                  source: 'c.rb',
                  method_ids: [],
                },
              ],
              modules: [
                {
                  name: 'A',
                },
              ],
            },
          ]
        )
      end
    end
  end
end
