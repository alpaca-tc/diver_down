# frozen_string_literal: true

RSpec.describe Diverdown::Definition::Source do
  describe 'ClassMethods' do
    describe '.from_hash' do
      it 'loads hash' do
        source = Diverdown::Definition::Source.new(
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
        )

        expect(described_class.from_hash(source.to_h)).to eq(source)
      end
    end
  end

  describe 'InstanceMethods' do
    describe '#dependency' do
      it 'adds non-duplicated dependencies' do
        source = described_class.new(source: 'a.rb')
        dependency_1 = source.dependency('b.rb')
        dependency_2 = source.dependency('b.rb')

        expect(source.dependencies).to eq(
          [
            Diverdown::Definition::Dependency.new(
              source: 'b.rb'
            ),
          ]
        )
        expect(dependency_1).to eq(dependency_2)
      end

      it "doesn't add self" do
        source = described_class.new(source: 'a.rb')
        dependency = source.dependency('a.rb')

        expect(source.dependencies).to eq([])
        expect(dependency).to be_nil
      end
    end

    describe '#<=>' do
      it 'compares sources' do
        sources = [
          described_class.new(source: 'a.rb'),
          described_class.new(source: 'b.rb'),
          described_class.new(source: 'c.rb'),
        ]

        expect(sources.shuffle.sort).to eq(sources)
      end
    end

    describe '#combine' do
      it 'combines simple sources' do
        source_a = described_class.new(
          source: 'a.rb'
        )

        source_b = described_class.new(
          source: 'a.rb'
        )

        expect(source_a.combine(source_b)).to eq(
          described_class.new(
            source: 'a.rb'
          )
        )
      end

      it 'raises exception if source is unmatched' do
        source_a = described_class.new(
          source: 'a.rb'
        )

        source_b = described_class.new(
          source: 'b.rb'
        )

        expect { source_a.combine(source_b) }.to raise_error(ArgumentError, 'source is unmatched. (a.rb, b.rb)')
      end

      it 'combines sources with dependencies' do
        source_a = described_class.new(
          source: 'a.rb',
          dependencies: [
            Diverdown::Definition::Dependency.new(
              source: 'b.rb'
            ),
            Diverdown::Definition::Dependency.new(
              source: 'c.rb'
            ),
          ]
        )

        source_b = described_class.new(
          source: 'a.rb',
          dependencies: [
            Diverdown::Definition::Dependency.new(
              source: 'b.rb',
              method_ids: [
                Diverdown::Definition::MethodId.new(
                  name: 'to_s',
                  context: 'class',
                  paths: ['a.rb']
                ),
              ]
            ),
            Diverdown::Definition::Dependency.new(
              source: 'd.rb'
            ),
          ]
        )

        expect(source_a.combine(source_b)).to eq(
          described_class.new(
            source: 'a.rb',
            dependencies: [
              Diverdown::Definition::Dependency.new(
                source: 'b.rb',
                method_ids: [
                  Diverdown::Definition::MethodId.new(
                    name: 'to_s',
                    context: 'class',
                    paths: ['a.rb']
                  ),
                ]
              ),
              Diverdown::Definition::Dependency.new(
                source: 'c.rb'
              ),
              Diverdown::Definition::Dependency.new(
                source: 'd.rb'
              ),
            ]
          )
        )
      end
    end

    describe '#hash' do
      it 'returns a hash' do
        source = described_class.new(source: 'a.rb')

        expect(source.hash).to eq(source.dup.hash)
      end
    end

    describe '#to_h' do
      it 'returns a yaml' do
        source = described_class.new(
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
          ],
          modules: [
            Diverdown::Definition::Modulee.new(
              name: 'A'
            ),
          ]
        )

        expect(source.to_h).to eq(
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
            },
          ],
          modules: [
            {
              name: 'A',
            },
          ]
        )
      end
    end
  end
end
