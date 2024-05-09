# frozen_string_literal: true

RSpec.describe DiverDown::Web::ModuleStore do
  describe 'InstanceMethods' do
    describe '#initialize' do
      it "does not raise error if file doesn't exist" do
        path = "#{Dir.tmpdir}/not_exist.yaml"
        expect { described_class.new(path) }.to_not raise_error
      end
    end

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

      it 'sorts by source name' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        sources = ['a.rb', 'b.rb', 'c.rb']

        sources.shuffle.each do |source|
          instance.set(source, ['A'])
        end

        expect {
          instance.flush
        }.to change {
          described_class.new(tempfile.path).instance_variable_get(:@store).keys
        }.from([]).to(sources)
      end
    end

    describe '#to_h' do
      it 'returns sorted hash' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        sources = ['a.rb', 'b.rb', 'c.rb']

        sources.shuffle.each do |source|
          instance.set(source, ['A'])
        end

        expect(instance.to_h.keys).to eq(sources)
      end
    end
  end
end
