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

    describe '#module/module=' do
      it 'read/write module' do
        instance = described_class.new

        expect {
          instance.module = 'A'
        }.to change {
          instance.module
        }.from(nil).to('A')
      end

      it 'set nil if given nil' do
        instance = described_class.new

        instance.module = nil
        expect(instance.module).to be_nil
      end
    end

    describe '#module?' do
      it 'returns bool' do
        instance = described_class.new

        expect {
          instance.module = 'A'
        }.to change {
          instance.module?
        }.from(false).to(true)
      end
    end

    describe '#to_h' do
      it 'returns hash' do
        instance = described_class.new
        expect(instance.to_h).to eq({})

        instance.memo = 'a'
        instance.module = 'A'

        expect(instance.to_h).to eq({ memo: 'a', module: 'A' })
      end
    end
  end
end
