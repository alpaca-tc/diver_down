# frozen_string_literal: true

RSpec.describe DiverDown::Trace::RedefineRubyMethods do
  describe 'ClassMethods' do
    describe '.redefine_c_methods' do
      it 'redefines c methods to ruby methods' do
        stub_const('A', Class.new)

        # Those are c methods
        expect(A.method(:name).source_location).to be_nil
        expect(A.instance_method(:initialize).source_location).to be_nil

        described_class.redefine_c_methods(
          A => {
            singleton: [:name],
            instance: [:initialize],
          }
        )

        # Those are ruby methods
        expect(A.method(:name).source_location).to_not be_nil
        expect(A.instance_method(:initialize).source_location).to_not be_nil
      end
    end
  end
end
