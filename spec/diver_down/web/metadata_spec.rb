# frozen_string_literal: true

RSpec.describe DiverDown::Web::Metadata do
  describe 'InstanceMethods' do
    def build_temp_path
      Tempfile.new(['test', '.yaml']).path
    end

    describe '#load' do
      it "does not raise error if file doesn't exist" do
        path = build_temp_path
        expect { described_class.new(path) }.to_not raise_error
      end
    end

    describe '#source' do
      it 'returns DiverDown::Web::Metadata::SourceMetadata' do
        path = build_temp_path
        instance = described_class.new(path)

        source_a = instance.source('a.rb')
        source_b = instance.source('b.rb')
        expect(source_a).to be_a(DiverDown::Web::Metadata::SourceMetadata)
        expect(source_b).to be_a(DiverDown::Web::Metadata::SourceMetadata)
      end
    end

    describe '#alias' do
      it 'returns DiverDown::Web::Metadata::SourceAlias' do
        path = build_temp_path
        instance = described_class.new(path)

        expect(instance.source_alias).to be_a(DiverDown::Web::Metadata::SourceAlias)
      end
    end

    describe '#flush' do
      it 'writes module to path' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)
        instance.source('a.rb').module = 'A'

        expect {
          instance.flush
        }.to change {
          described_class.new(tempfile.path).source('a.rb').module
        }.from(nil).to('A')
      end

      it 'writes memo to path' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)
        instance.source('a.rb').memo = 'memo'

        expect {
          instance.flush
        }.to change {
          described_class.new(tempfile.path).source('a.rb').memo
        }.from('').to('memo')
      end

      it 'writes alias to path' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)
        instance.source_alias.update_alias('A', ['C', 'B'])

        expect {
          instance.flush
        }.to change {
          described_class.new(tempfile.path).source_alias.aliased_source_names('A')
        }.from(nil).to(['B', 'C'])
      end

      it 'sorts by source name' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        sources = ['a.rb', 'b.rb', 'c.rb']

        sources.shuffle.each do |source|
          instance.source(source).module = 'A'
        end

        expect {
          instance.flush
        }.to change {
          described_class.new(tempfile.path).instance_variable_get(:@source_map).keys
        }.from([]).to(sources)
      end
    end

    describe '#to_h' do
      it 'returns sorted hash' do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        source_names = ['a.rb', 'b.rb', 'c.rb']

        source_names.shuffle.each do |source_name|
          source = instance.source(source_name)
          source.module = 'A'
          source.memo = 'memo'
        end

        expect(instance.to_h[:sources].keys).to eq(source_names)
      end

      it "doesn't include blank source" do
        tempfile = Tempfile.new(['test', '.yaml'])
        instance = described_class.new(tempfile.path)

        instance.source('a.rb')

        expect(instance.to_h[:sources].keys).to eq([])
      end
    end
  end
end
