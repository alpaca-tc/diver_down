# frozen_string_literal: true

RSpec.describe Diverdown::Definition::MethodId do
  describe 'InstanceMethods' do
    describe '#human_method_name' do
      it 'returns a string' do
        expect(described_class.new(name: 'to_s', context: 'class').human_method_name).to eq('.to_s')
        expect(described_class.new(name: 'to_s', context: 'instance').human_method_name).to eq('#to_s')
      end
    end

    describe '#hash' do
      it 'returns a hash' do
        method_id_1 = described_class.new(name: 'to_s', context: 'class')
        method_id_2 = described_class.new(name: 'to_s', context: 'class')
        method_id_3 = described_class.new(name: 'to_i', context: 'class')
        method_id_4 = described_class.new(name: 'to_i', context: 'class')
        method_id_4.add_path('a.rb')
        method_id_5 = described_class.new(name: 'to_s', context: 'instance')

        expect(method_id_1.hash).to eq(method_id_2.hash)
        expect(method_id_1.hash).to_not eq(method_id_3.hash)

        expect(method_id_4.hash).to eq(method_id_4.dup.hash)
        expect(method_id_3.hash).to_not eq(method_id_4.dup.hash)
        expect(method_id_1.hash).to_not eq(method_id_5.hash)
      end
    end

    describe '#<=>' do
      it 'compares with other' do
        array = [
          described_class.new(
            name: 'a',
            context: 'class'
          ),
          described_class.new(
            name: 'b',
            context: 'class'
          ),
          described_class.new(
            name: 'b',
            context: 'instance'
          ),
          described_class.new(
            name: 'c',
            context: 'class'
          ),
        ].shuffle

        expect(array.sort.map(&:name)).to eq(%w[a b b c])
        expect(array.sort.map(&:context)).to eq(%w[class class instance class])
      end
    end

    describe '#==' do
      it 'compares with other' do
        method_id = described_class.new(name: 'A', context: 'class', paths: ['a.rb'])

        expect(method_id).to eq(described_class.new(name: 'A', context: 'class', paths: ['a.rb']))
        expect(method_id).to_not eq(described_class.new(name: 'A', context: 'instance', paths: ['a.rb']))
        expect(method_id).to_not eq(described_class.new(name: 'A', context: 'class', paths: ['b.rb']))
        expect(method_id).to_not eq(described_class.new(name: 'B', context: 'class', paths: ['a.rb']))
        expect(method_id).to_not eq(Object.new)
      end
    end

    describe '#to_h' do
      it 'returns a hash' do
        method_id = described_class.new(
          name: 'to_s',
          context: 'class',
          paths: ['b.rb', 'a.rb']
        )

        expect(method_id.to_h).to eq(
          name: 'to_s',
          context: 'class',
          paths: ['a.rb', 'b.rb']
        )
      end
    end
  end
end
