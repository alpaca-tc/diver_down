# frozen_string_literal: true

RSpec.describe DiverDown::Definition::Dependency do
  describe 'ClassMethods' do
    describe '.from_hash' do
      it 'loads hash' do
        dependency = described_class.new(
          source_name: 'a.rb',
          method_ids: [
            DiverDown::Definition::MethodId.new(
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
          source_name: 'b.rb',
          method_ids: [
            DiverDown::Definition::MethodId.new(
              name: 'to_s',
              context: 'class',
              paths: ['a.rb']
            ),
          ]
        )

        dependency_b = described_class.new(
          source_name: 'b.rb',
          method_ids: [
            DiverDown::Definition::MethodId.new(
              name: 'to_s',
              context: 'class',
              paths: ['b.rb']
            ),
            DiverDown::Definition::MethodId.new(
              name: 'to_i',
              context: 'class',
              paths: ['b.rb']
            ),
            DiverDown::Definition::MethodId.new(
              name: 'to_i',
              context: 'instance',
              paths: ['c.rb']
            ),
          ]
        )

        dependency_c = described_class.new(
          source_name: 'c.rb',
          method_ids: [
            DiverDown::Definition::MethodId.new(
              name: 'to_z',
              context: 'class',
              paths: ['c.rb']
            ),
          ]
        )

        expect(described_class.combine(dependency_a, dependency_b, dependency_c)).to eq(
          [
            described_class.new(
              source_name: 'b.rb',
              method_ids: [
                DiverDown::Definition::MethodId.new(
                  name: 'to_s',
                  context: 'class',
                  paths: ['a.rb', 'b.rb']
                ),
                DiverDown::Definition::MethodId.new(
                  name: 'to_i',
                  context: 'class',
                  paths: ['b.rb']
                ),
                DiverDown::Definition::MethodId.new(
                  name: 'to_i',
                  context: 'instance',
                  paths: ['c.rb']
                ),
              ]
            ),
            described_class.new(
              source_name: 'c.rb',
              method_ids: [
                DiverDown::Definition::MethodId.new(
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
        source = described_class.new(source_name: 'a.rb')

        expect(source.hash).to eq(described_class.new(source_name: 'a.rb').hash)
        expect(source.hash).to_not eq(described_class.new(source_name: 'b.rb').hash)
        expect(source.hash).to_not eq(
          described_class.new(
            source_name: 'a.rb',
            method_ids: [
              DiverDown::Definition::MethodId.new(
                name: 'A',
                context: 'class'
              ),
            ]
          ).hash
        )
      end
    end

    describe '#find_or_build_method_id' do
      it 'returns existing method_id if method_id exists' do
        class_method_id = DiverDown::Definition::MethodId.new(
          name: 'to_s',
          context: 'class',
          paths: ['a.rb']
        )
        instance_method_id = DiverDown::Definition::MethodId.new(
          name: 'to_s',
          context: 'instance',
          paths: ['a.rb']
        )

        dependency = described_class.new(
          source_name: 'a.rb',
          method_ids: [class_method_id, instance_method_id]
        )

        expect(dependency.find_or_build_method_id(name: 'to_s', context: 'class')).to eq(class_method_id)
      end

      it "returns new method_id if method_id doesn't exist" do
        method_id = DiverDown::Definition::MethodId.new(
          name: 'to_s',
          context: 'class',
          paths: ['a.rb']
        )
        dependency = described_class.new(
          source_name: 'a.rb',
          method_ids: [method_id]
        )

        expect(dependency.find_or_build_method_id(name: 'to_i', context: 'class')).to eq(
          DiverDown::Definition::MethodId.new(
            context: 'class',
            name: 'to_i'
          )
        )
      end
    end

    describe '#method_id' do
      it 'returns existing method_id if method_id exists' do
        class_method_id = DiverDown::Definition::MethodId.new(
          name: 'to_s',
          context: 'class',
          paths: ['a.rb']
        )
        instance_method_id = DiverDown::Definition::MethodId.new(
          name: 'to_s',
          context: 'instance',
          paths: ['a.rb']
        )

        dependency = described_class.new(
          source_name: 'a.rb',
          method_ids: [class_method_id, instance_method_id]
        )

        expect(dependency.method_id(name: 'to_s', context: 'class')).to eq(class_method_id)
        expect(dependency.method_id(name: 'to_s', context: 'instance')).to eq(instance_method_id)
        expect(dependency.method_id(name: 'unknown', context: 'class')).to be_nil
      end
    end

    describe '#to_h' do
      it 'returns a hash' do
        dependency = described_class.new(
          source_name: 'a.rb',
          method_ids: [
            DiverDown::Definition::MethodId.new(
              name: 'A',
              context: 'class',
              paths: ['a.rb']
            ),
          ]
        )

        expect(dependency.to_h).to eq(
          source_name: 'a.rb',
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
            source_name: 'a.rb'
          ),
          described_class.new(
            source_name: 'b.rb'
          ),
          described_class.new(
            source_name: 'c.rb'
          ),
        ].shuffle

        expect(array.sort.map(&:source_name)).to eq(%w[a.rb b.rb c.rb])
      end
    end
  end
end
