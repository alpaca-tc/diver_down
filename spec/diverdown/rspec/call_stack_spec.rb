# frozen_string_literal: true

RSpec.describe Diverdown::RSpec::CallStack do
  describe 'InstanceMethods' do
    describe '#pop' do
      it 'raises error if stack is empty' do
        stack = described_class.new
        expect { stack.pop }.to raise_error(described_class::StackEmptyError)

        stack.push
        expect { stack.pop }.to_not raise_error
      end
    end

    describe '#stack/push/pop' do
      it 'pushes and pops' do
        stack = described_class.new

        stack.push
        stack.push('A')
        stack.push
        stack.push('B')
        stack.push
        stack.push('C')

        expect(stack.stack).to eq(['A', 'B', 'C'])
        stack.pop

        expect(stack.stack).to eq(['A', 'B'])
        stack.pop
        expect(stack.stack).to eq(['A', 'B'])
        stack.pop

        expect(stack.stack).to eq(['A'])
        stack.pop
        expect(stack.stack).to eq(['A'])
        stack.pop

        expect(stack.stack).to eq([])
      end
    end

    describe '#empty?' do
      it 'returns true if stack is not empty' do
        stack = described_class.new
        expect(stack.empty?).to eq(true)

        stack.push
        expect(stack.empty?).to eq(true)

        stack.push('A')
        expect(stack.empty?).to eq(false)
      end
    end
  end
end
