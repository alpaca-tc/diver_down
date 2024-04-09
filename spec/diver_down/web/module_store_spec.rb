# frozen_string_literal: true

RSpec.describe DiverDown::Web::ModuleStore do
  describe 'InstanceMethods' do
    describe '#set' do
      it 'set modules to source' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        expect {
          instance.set('a.rb', ['A', 'B'])
        }.to change {
          instance.get('a.rb')
        }.from([]).to(['A', 'B'])
      end
    end

    describe '#get' do
      it 'returns blank array if source is not set' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        expect(instance.get('a.rb')).to eq([])

        instance.set('a.rb', ['A', 'B'])
        expect(instance.get('a.rb')).to eq(['A', 'B'])
      end
    end

    describe '#flush' do
      it 'writes modules to path' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)
        instance.set('a.rb', ['A', 'B'])

        expect {
          instance.flush
        }.to change {
          described_class.new(tempfile.path).get('a.rb')
        }.from([]).to(['A', 'B'])
      end
    end
  end
end
