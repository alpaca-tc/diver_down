# frozen_string_literal: true

RSpec.describe DiverDown::Trace::CallStack do
  describe 'InstanceMethods' do
    describe '#pop' do
      it 'raises error if stack is empty' do
        stack = described_class.new
        expect { stack.pop }.to raise_error(described_class::StackEmptyError)

        stack.push
        expect { stack.pop }.to_not raise_error
      end
    end

    describe '#context_stack/#context_stack_size/push/pop' do
      it 'pushes and pops' do
        stack = described_class.new

        stack.push
        stack.push('A')
        stack.push
        stack.push('B')
        stack.push
        stack.push('C')

        expect(stack.context_stack).to eq(['A', 'B', 'C'])
        expect(stack.context_stack_size).to eq([2, 4, 6])
        stack.pop

        expect(stack.context_stack).to eq(['A', 'B'])
        expect(stack.context_stack_size).to eq([2, 4])
        stack.pop
        expect(stack.context_stack).to eq(['A', 'B'])
        expect(stack.context_stack_size).to eq([2, 4])
        stack.pop

        expect(stack.context_stack).to eq(['A'])
        expect(stack.context_stack_size).to eq([2])
        stack.pop
        expect(stack.context_stack).to eq(['A'])
        expect(stack.context_stack_size).to eq([2])
        stack.pop

        expect(stack.context_stack).to eq([])
        expect(stack.context_stack_size).to eq([])
      end

      context 'with _ignored: true' do
        it 'marks current stack as ignored' do
          stack = described_class.new

          stack.push
          stack.push(ignored: true)
          stack.push

          expect(stack.ignored?).to be(true)
          stack.pop
          expect(stack.ignored?).to be(true)
          stack.pop
          expect(stack.ignored?).to be(false)
          stack.pop
          expect(stack.ignored?).to be(false)
        end
      end
    end

    describe '#empty_context_stack?' do
      it 'returns true if stack is not empty' do
        stack = described_class.new
        expect(stack.empty_context_stack?).to eq(true)

        stack.push
        expect(stack.empty_context_stack?).to eq(true)

        stack.push('A')
        expect(stack.empty_context_stack?).to eq(false)
      end
    end
  end
end
