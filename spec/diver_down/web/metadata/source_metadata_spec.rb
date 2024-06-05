# frozen_string_literal: true

RSpec.describe DiverDown::Web::Metadata::SourceMetadata do
  describe 'InstanceMethods' do
    describe '#memo/#memo=' do
      it 'read/write memo' do
        instance = described_class.new

        expect {
          instance.memo = 'memo'
        }.to change {
          instance.memo
        }.from('').to('memo')
      end
    end

    describe '#modules/modules=' do
      it 'read/write modules' do
        instance = described_class.new

        expect {
          instance.modules = ['A', 'B']
        }.to change {
          instance.modules
        }.from([]).to(['A', 'B'])
      end
    end

    describe '#modules?' do
      it 'returns bool' do
        instance = described_class.new

        expect {
          instance.modules = ['A', 'B']
        }.to change {
          instance.modules?
        }.from(false).to(true)
      end
    end

    describe '#to_h' do
      it 'returns hash' do
        instance = described_class.new
        expect(instance.to_h).to eq({})

        instance.memo = 'a'
        instance.modules = ['A']

        expect(instance.to_h).to eq({ memo: 'a', modules: ['A'] })
      end
    end
  end
end
