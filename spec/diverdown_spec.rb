# frozen_string_literal: true

RSpec.describe Diverdown do
  describe 'ClassMethods' do
    describe '.configuration' do
      it { expect(Diverdown.configuration).to be_a(Hash) }
    end
  end
end
