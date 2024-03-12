# frozen_string_literal: true

RSpec.describe Diverdown::Definition::Dependency do
  describe 'ClassMethods' do
    describe '.from_hash' do
      it 'loads hash' do
        dependency = described_class.new(
          source: 'a.rb',
          method_ids: [
            Diverdown::Definition::MethodId.new(
              name: 'A',
              context: 'class',
              paths: ['a.rb']
            ),
          ]
        )

        expect(described_class.from_hash(dependency.to_h)).to eq(dependency)
      end
    end

    describe '.combine' do
      it 'combines with other' do
        dependency_a = described_class.new(
          source: 'b.rb',
          method_ids: [
            Diverdown::Definition::MethodId.new(
              name: 'to_s',
              context: 'class',
              paths: ['a.rb']
            ),
          ]
        )

        dependency_b = described_class.new(
          source: 'b.rb',
          method_ids: [
            Diverdown::Definition::MethodId.new(
              name: 'to_s',
              context: 'class',
              paths: ['b.rb']
            ),
            Diverdown::Definition::MethodId.new(
              name: 'to_i',
              context: 'class',
              paths: ['b.rb']
            ),
            Diverdown::Definition::MethodId.new(
              name: 'to_i',
              context: 'instance',
              paths: ['c.rb']
            ),
          ]
        )

        dependency_c = described_class.new(
          source: 'c.rb',
          method_ids: [
            Diverdown::Definition::MethodId.new(
              name: 'to_z',
              context: 'class',
              paths: ['c.rb']
            ),
          ]
        )

        expect(described_class.combine(dependency_a, dependency_b, dependency_c)).to eq(
          [
            described_class.new(
              source: 'b.rb',
              method_ids: [
                Diverdown::Definition::MethodId.new(
                  name: 'to_s',
                  context: 'class',
                  paths: ['a.rb', 'b.rb']
                ),
                Diverdown::Definition::MethodId.new(
                  name: 'to_i',
                  context: 'class',
                  paths: ['b.rb']
                ),
                Diverdown::Definition::MethodId.new(
                  name: 'to_i',
                  context: 'instance',
                  paths: ['c.rb']
                ),
              ]
            ),
            described_class.new(
              source: 'c.rb',
              method_ids: [
                Diverdown::Definition::MethodId.new(
                  name: 'to_z',
                  context: 'class',
                  paths: ['c.rb']
                ),
              ]
            ),
          ]
        )
      end
    end
  end

  describe 'InstanceMethods' do
    describe '#hash' do
      it 'returns a hash' do
        source = described_class.new(source: 'a.rb')

        expect(source.hash).to eq(described_class.new(source: 'a.rb').hash)
        expect(source.hash).to_not eq(described_class.new(source: 'b.rb').hash)
        expect(source.hash).to_not eq(
          described_class.new(
            source: 'a.rb',
            method_ids: [
              Diverdown::Definition::MethodId.new(
                name: 'A',
                context: 'class'
              ),
            ]
          ).hash
        )
      end
    end

    describe '#method_id' do
      it 'returns existing method_id if method_id exists' do
        class_method_id = Diverdown::Definition::MethodId.new(
          name: 'to_s',
          context: 'class',
          paths: ['a.rb']
        )
        instance_method_id = Diverdown::Definition::MethodId.new(
          name: 'to_s',
          context: 'instance',
          paths: ['a.rb']
        )

        dependency = described_class.new(
          source: 'a.rb',
          method_ids: [class_method_id, instance_method_id]
        )

        expect(dependency.method_id(name: 'to_s', context: 'class')).to eq(class_method_id)
      end

      it "returns new method_id if method_id doesn't exist" do
        method_id = Diverdown::Definition::MethodId.new(
          name: 'to_s',
          context: 'class',
          paths: ['a.rb']
        )
        dependency = described_class.new(
          source: 'a.rb',
          method_ids: [method_id]
        )

        expect(dependency.method_id(name: 'to_i', context: 'class')).to eq(
          Diverdown::Definition::MethodId.new(
            context: 'class',
            name: 'to_i'
          )
        )
      end
    end

    describe '#to_h' do
      it 'returns a hash' do
        dependency = described_class.new(
          source: 'a.rb',
          method_ids: [
            Diverdown::Definition::MethodId.new(
              name: 'A',
              context: 'class',
              paths: ['a.rb']
            ),
          ]
        )

        expect(dependency.to_h).to eq(
          source: 'a.rb',
          method_ids: [
            {
              name: 'A',
              context: 'class',
              paths: ['a.rb'],
            },
          ]
        )
      end
    end

    describe '#<=>' do
      it 'compares with other' do
        array = [
          described_class.new(
            source: 'a.rb'
          ),
          described_class.new(
            source: 'b.rb'
          ),
          described_class.new(
            source: 'c.rb'
          ),
        ].shuffle

        expect(array.sort.map(&:source)).to eq(%w[a.rb b.rb c.rb])
      end
    end
  end
end
