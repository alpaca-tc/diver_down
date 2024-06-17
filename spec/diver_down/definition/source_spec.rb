# frozen_string_literal: true

RSpec.describe DiverDown::Definition::Source do
  describe 'ClassMethods' do
    describe '.from_hash' do
      it 'loads hash' do
        source = DiverDown::Definition::Source.new(
          source_name: 'a.rb',
          dependencies: [
            DiverDown::Definition::Dependency.new(
              source_name: 'b.rb',
              method_ids: [
                DiverDown::Definition::MethodId.new(
                  name: 'A',
                  context: 'class',
                  paths: ['a.rb']
                ),
              ]
            ),
            DiverDown::Definition::Dependency.new(
              source_name: 'c.rb'
            ),
          ]
        )

        expect(described_class.from_hash(source.to_h)).to eq(source)
      end
    end

    describe '.combine' do
      it 'combines simple sources' do
        source_a = described_class.new(
          source_name: 'a.rb'
        )

        source_b = described_class.new(
          source_name: 'a.rb'
        )

        expect(described_class.combine(source_a, source_b)).to eq(
          described_class.new(
            source_name: 'a.rb'
          )
        )
      end

      it 'raises exception if sources are empty' do
        expect { described_class.combine }.to raise_error(ArgumentError, 'sources are empty')
      end

      it 'raises exception if source is unmatched' do
        source_a = described_class.new(
          source_name: 'a.rb'
        )

        source_b = described_class.new(
          source_name: 'b.rb'
        )

        expect { described_class.combine(source_a, source_b) }.to raise_error(ArgumentError, 'sources are unmatched. (["a.rb", "b.rb"])')
      end

      it 'combines sources with dependencies' do
        source_a = described_class.new(
          source_name: 'a.rb',
          dependencies: [
            DiverDown::Definition::Dependency.new(
              source_name: 'b.rb'
            ),
            DiverDown::Definition::Dependency.new(
              source_name: 'c.rb'
            ),
          ]
        )

        source_b = described_class.new(
          source_name: 'a.rb',
          dependencies: [
            DiverDown::Definition::Dependency.new(
              source_name: 'b.rb',
              method_ids: [
                DiverDown::Definition::MethodId.new(
                  name: 'to_s',
                  context: 'class',
                  paths: ['a.rb']
                ),
              ]
            ),
            DiverDown::Definition::Dependency.new(
              source_name: 'd.rb'
            ),
          ]
        )

        expect(described_class.combine(source_a, source_b)).to eq(
          described_class.new(
            source_name: 'a.rb',
            dependencies: [
              DiverDown::Definition::Dependency.new(
                source_name: 'b.rb',
                method_ids: [
                  DiverDown::Definition::MethodId.new(
                    name: 'to_s',
                    context: 'class',
                    paths: ['a.rb']
                  ),
                ]
              ),
              DiverDown::Definition::Dependency.new(
                source_name: 'c.rb'
              ),
              DiverDown::Definition::Dependency.new(
                source_name: 'd.rb'
              ),
            ]
          )
        )
      end
    end
  end

  describe 'InstanceMethods' do
    describe '#find_or_build_dependency' do
      it 'adds non-duplicated dependencies' do
        source = described_class.new(source_name: 'a.rb')
        dependency_1 = source.find_or_build_dependency('b.rb')
        dependency_2 = source.find_or_build_dependency('b.rb')

        expect(source.dependencies).to eq(
          [
            DiverDown::Definition::Dependency.new(
              source_name: 'b.rb'
            ),
          ]
        )
        expect(dependency_1).to eq(dependency_2)
      end

      it "doesn't add self" do
        source = described_class.new(source_name: 'a.rb')
        dependency = source.find_or_build_dependency('a.rb')

        expect(source.dependencies).to eq([])
        expect(dependency).to be_nil
      end
    end

    describe '#dependency' do
      it 'returns dependency if it is found' do
        source = described_class.new(source_name: 'a.rb')
        dependency = source.find_or_build_dependency('b.rb')

        expect(source.dependency(dependency.source_name)).to eq(dependency)
        expect(source.dependency('unknown')).to be_nil
      end
    end

    describe '#delete_dependency' do
      it 'deletes dependency' do
        source = described_class.new(source_name: 'a.rb')
        dependency = source.find_or_build_dependency('b.rb')

        expect(source.dependency(dependency.source_name)).to eq(dependency)

        source.delete_dependency(dependency.source_name)

        expect(source.dependency(dependency.source_name)).to be_nil
      end
    end

    describe '#<=>' do
      it 'compares sources' do
        sources = [
          described_class.new(source_name: 'a.rb'),
          described_class.new(source_name: 'b.rb'),
          described_class.new(source_name: 'c.rb'),
        ]

        expect(sources.shuffle.sort).to eq(sources)
      end
    end

    describe '#hash' do
      it 'returns a hash' do
        source = described_class.new(source_name: 'a.rb')

        expect(source.hash).to eq(source.dup.hash)
      end
    end

    describe '#to_h' do
      it 'returns a yaml' do
        source = described_class.new(
          source_name: 'a.rb',
          dependencies: [
            DiverDown::Definition::Dependency.new(
              source_name: 'b.rb',
              method_ids: [
                DiverDown::Definition::MethodId.new(
                  name: 'A',
                  context: 'class',
                  paths: ['a.rb']
                ),
              ]
            ),
          ]
        )

        expect(source.to_h).to eq(
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
            },
          ]
        )
      end
    end

    describe '#freeze' do
      it 'freezes instance' do
        source = described_class.new(source_name: 'a.rb')
        dependency = source.find_or_build_dependency('b.rb')
        method_id = dependency.find_or_build_method_id(name: 'to_s', context: 'class')

        expect(source).to_not be_frozen
        source.freeze
        expect(source).to be_frozen

        expect { source.find_or_build_dependency('c.rb') }.to raise_error(FrozenError)
        expect { dependency.find_or_build_method_id(name: 'unknown', context: 'class') }.to raise_error(FrozenError)
        expect { method_id.add_path('a.rb') }.to raise_error(FrozenError)
      end
    end
  end
end
