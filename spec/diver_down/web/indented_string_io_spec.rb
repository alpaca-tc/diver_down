# frozen_string_literal: true

RSpec.describe DiverDown::IndentedStringIo do
  describe 'InstanceMethods' do
    describe '#write' do
      it 'writes string' do
        io = described_class.new
        io.write('line')

        expect(io.string).to eq('line')
      end

      it 'writes indented string' do
        io = described_class.new
        io.indent = 1
        io.write('line')

        expect(io.string).to eq('  line')
      end

      it 'writes multiple indented contents' do
        io = described_class.new
        io.indent = 1
        io.write('1', '2', '3')

        expect(io.string).to eq('  123')
      end

      it 'writes string without indent when indent: false' do
        io = described_class.new
        io.indent = 1
        io.write('1', indent: false)

        expect(io.string).to eq('1')
      end
    end

    describe '#puts' do
      it 'writes line' do
        io = described_class.new
        io.puts('line')

        expect(io.string).to eq("line\n")
      end

      it 'writes indented line' do
        io = described_class.new
        io.indent = 1
        io.puts('line')

        expect(io.string).to eq("  line\n")
      end

      it 'writes multiple indented line' do
        io = described_class.new
        io.puts('start')
        io.indent = 1
        io.puts(<<~EOS)
          1
          2

          4
        EOS

        expect(io.string).to eq(<<~EOS)
          start
            1
            2

            4

        EOS
      end

      it 'writes string without indent when indent: false' do
        io = described_class.new
        io.indent = 1
        io.puts('1', indent: false)

        expect(io.string).to eq("1\n")
      end
    end

    describe '#indented' do
      it 'writes indented line' do
        io = described_class.new
        io.indented do
          io.puts('line')
        end

        expect(io.string).to eq("  line\n")

        io.puts('next line')
        expect(io.string.lines[-1]).to eq("next line\n")
      end
    end
  end
end
