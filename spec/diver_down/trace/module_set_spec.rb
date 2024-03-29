# frozen_string_literal: true

RSpec.describe DiverDown::Trace::ModuleSet do
  describe 'InstanceMethods' do
    describe '#include?' do
      context 'with modules' do
        it 'checks module or module name' do
          stub_const('A', Module.new)
          stub_const('B', Module.new)

          set = described_class.new(
            modules: [A]
          )

          expect(set.include?(A)).to be(true)
          expect(set.include?(B)).to be(false)
        end

        it 'checks superclass' do
          stub_const('A', Class.new)
          stub_const('B', Class.new(A))
          stub_const('C', Class.new(B))

          set = described_class.new(
            modules: [B]
          )

          expect(set.include?(A)).to be(false)
          expect(set.include?(B)).to be(true)
          expect(set.include?(C)).to be(true)
        end
      end

      context 'const_source_location strategy' do
        def ensure_remove_module(*names)
          yield
        ensure
          names.each do
            Object.send(:remove_const, _1)
          end
        end

        it 'checks module or module name' do
          ensure_remove_module('A') do
            # rubocop:disable Lint/ConstantDefinitionInBlock
            class ::A
            end
            # rubocop:enable Lint/ConstantDefinitionInBlock

            set = described_class.new(
              include: [__FILE__]
            )

            expect(set.include?(A)).to be(true)
            expect(set.include?(::DiverDown)).to be(false)
          end
        end

        it 'checks superclass' do
          ensure_remove_module('A', 'B') do
            # rubocop:disable Lint/ConstantDefinitionInBlock
            class ::A < DiverDown::Trace::ModuleSet; end
            class ::B < ::A; end
            # rubocop:enable Lint/ConstantDefinitionInBlock

            set = described_class.new(
              include: [__FILE__]
            )

            expect(set.include?(A)).to be(true)
            expect(set.include?(B)).to be(true)
            expect(set.include?(DiverDown::Trace::ModuleSet)).to be(false)
          end
        end
      end
    end
  end
end
