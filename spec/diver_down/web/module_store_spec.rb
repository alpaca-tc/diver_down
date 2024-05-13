# frozen_string_literal: true

RSpec.describe DiverDown::Web::ModuleStore do
  describe 'InstanceMethods' do
    describe '#initialize' do
      it "does not raise error if file doesn't exist" do
        path = "#{Dir.tmpdir}/not_exist.yaml"
        expect { described_class.new(path) }.to_not raise_error
      end
    end

    describe '#set_modules' do
      it 'set_modules modules to source' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        expect {
          instance.set_modules('a.rb', ['A', 'B'])
        }.to change {
          instance.get_modules('a.rb')
        }.from([]).to(['A', 'B'])
      end
    end

    describe '#get_modules' do
      it 'returns blank array if source is not set_modules' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        expect(instance.get_modules('a.rb')).to eq([])

        instance.set_modules('a.rb', ['A', 'B'])
        expect(instance.get_modules('a.rb')).to eq(['A', 'B'])
      end
    end

    describe '#set_memo' do
      it 'sets memo' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        expect {
          instance.set_memo('a.rb', ' memo ')
        }.to change {
          instance.get_memo('a.rb')
        }.from('').to('memo')
      end
    end

    describe '#get_memo' do
      it 'returns blank string if source is not set_modules' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        expect(instance.get_memo('a.rb')).to eq('')

        instance.set_memo('a.rb', 'a')
        expect(instance.get_memo('a.rb')).to eq('a')
      end
    end

    describe '#classified?' do
      it 'returns bool' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        instance.set_modules('a.rb', [])
        instance.set_modules('b.rb', ['A'])

        expect(instance.classified?('a.rb')).to be(false)
        expect(instance.classified?('b.rb')).to be(true)
        expect(instance.classified?('c.rb')).to be(false)
      end
    end

    describe '#flush' do
      it 'writes modules to path' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)
        instance.set_modules('a.rb', ['A', 'B'])

        expect {
          instance.flush
        }.to change {
          described_class.new(tempfile.path).get_modules('a.rb')
        }.from([]).to(['A', 'B'])
      end

      it 'writes memo to path' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)
        instance.set_memo('a.rb', 'memo')

        expect {
          instance.flush
        }.to change {
          described_class.new(tempfile.path).get_memo('a.rb')
        }.from('').to('memo')
      end

      it 'sorts by source name' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        sources = ['a.rb', 'b.rb', 'c.rb']

        sources.shuffle.each do |source|
          instance.set_modules(source, ['A'])
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
          instance.set_modules(source, ['A'])
          instance.set_memo(source, 'memo')
        end

        expect(instance.to_h.keys).to eq(sources)
      end
    end
  end
end
