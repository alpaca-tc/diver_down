# frozen_string_literal: true

RSpec.describe DiverDown::Trace::IgnoredMethodIds do
  describe 'InstanceMethods' do
    describe '#ignored' do
      it 'returns false if ignored_methods are blank' do
        stub_const('A', Class.new)

        ignored_method = described_class.new({})

        expect(ignored_method.ignored(A, true, 'new')).to be(false)
      end

      it 'returns :all if class is ignored as :all' do
        stub_const('A', Class.new)
        stub_const('B', Class.new)
        stub_const('C', Class.new(A))

        ignored_method = described_class.new(
          'A' => :all
        )

        expect(ignored_method.ignored(A, true, :new)).to be(:all)
        expect(ignored_method.ignored(B, true, :new)).to be(false)
        expect(ignored_method.ignored(C, true, :new)).to be(:all)
      end

      it 'returns :single if class is ignored as :single' do
        stub_const('A', Class.new)
        stub_const('B', Class.new)
        stub_const('C', Class.new(A))

        ignored_method = described_class.new(
          'A' => :single
        )

        expect(ignored_method.ignored(A, true, :new)).to be(:single)
        expect(ignored_method.ignored(B, true, :new)).to be(false)
        expect(ignored_method.ignored(C, true, :new)).to be(:single)
      end

      it 'does not lookup the ancestors if module given because of the complexity of implementation' do
        stub_const('A', Module.new)
        stub_const('B', Module.new)
        stub_const('C', Module.new.tap { _1.extend(A) })

        ignored_method = described_class.new(
          'A.name' => :all
        )

        expect(ignored_method.ignored(A, true, :name)).to be(:all)
        expect(ignored_method.ignored(B, true, :name)).to be(false)
        expect(ignored_method.ignored(C, true, :name)).to be(false)
      end

      it 'returns true if class method is matched' do
        stub_const('A', Class.new)
        stub_const('B', Class.new)
        stub_const('C', Class.new(A))

        ignored_method = described_class.new(
          'A.new' => :all
        )

        expect(ignored_method.ignored(A, true, :new)).to be(:all)
        expect(ignored_method.ignored(B, true, :new)).to be(false)
        expect(ignored_method.ignored(C, true, :new)).to be(:all)
      end

      it 'returns true if instance method is matched' do
        stub_const('A', Class.new)
        stub_const('B', Class.new)
        stub_const('C', Class.new(A))

        ignored_method = described_class.new(
          'A#initialize' => :all
        )

        expect(ignored_method.ignored(A, false, :initialize)).to be(:all)
        expect(ignored_method.ignored(B, false, :initialize)).to be(false)
        expect(ignored_method.ignored(C, false, :initialize)).to be(:all)
      end
    end
  end
end
