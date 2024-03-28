# frozen_string_literal: true

RSpec.describe DiverDown::Trace::ModuleSet do
  describe 'InstanceMethods' do
    describe '#include?' do
      it 'checks module or module name' do
        stub_const('A', Module.new)
        stub_const('B', Module.new)

        set = described_class.new(
          [A]
        )

        expect(set.include?(A)).to be(true)
        expect(set.include?(B)).to be(false)

        expect(set.include?('A')).to be(true)
        expect(set.include?('B')).to be(false)
      end

      it 'checks superclass' do
        stub_const('A', Class.new)
        stub_const('B', Class.new(A))
        stub_const('C', Class.new(B))

        set = described_class.new(
          [B]
        )

        expect(set.include?(A)).to be(false)
        expect(set.include?(B)).to be(true)
        expect(set.include?(C)).to be(true)

        expect(set.include?('A')).to be(false)
        expect(set.include?('B')).to be(true)
        expect(set.include?('C')).to be(true)
      end
    end
  end
end
