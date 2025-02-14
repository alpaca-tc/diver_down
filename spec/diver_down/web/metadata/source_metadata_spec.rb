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

    describe '#dependency_types/dependency_type/dependency_types=/update_dependency_type' do
      it 'read/write dependency_types' do
        instance = described_class.new

        expect {
          instance.dependency_types = { 'A' => 'valid' }
        }.to change {
          instance.dependency_types
        }.from({}).to({ 'A' => 'valid' })
      end

      it 'read dependency_type' do
        instance = described_class.new
        expect(instance.dependency_type('A')).to be_nil

        instance.dependency_types = { 'A' => 'valid' }

        expect(instance.dependency_type('A')).to eq('valid')
      end

      it 'raises error if given invalid dependency_type' do
        instance = described_class.new
        valid = ['valid', 'invalid', 'todo']
        invalid = 'invalid2'

        expect {
          valid.each do
            instance.update_dependency_type('A', _1)
          end
        }.to_not raise_error

        expect {
          instance.update_dependency_type('A', invalid)
        }.to raise_error(ArgumentError, "invalid dependency_type: #{invalid}")
      end

      it 'update dependency_type' do
        instance = described_class.new
        instance.dependency_types = { 'A' => 'valid' }

        expect {
          instance.update_dependency_type('A', 'invalid')
        }.to change {
          instance.dependency_types
        }.from({ 'A' => 'valid' }).to({ 'A' => 'invalid' })
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
