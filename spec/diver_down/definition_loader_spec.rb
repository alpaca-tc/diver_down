# frozen_string_literal: true

RSpec.describe DiverDown::DefinitionStore do
  describe 'InstanceMethods' do
    describe '#load_file' do
      it 'loads yaml' do
        dir = Dir.mktmpdir
        path = File.join(dir, 'a.yaml')

        definition = DiverDown::Definition.new(title: 'a')
        File.write(path, definition.to_h.to_yaml)

        loader = DiverDown::DefinitionLoader.new

        expect(loader.load_file(path)).to eq(definition)
      end

      it 'loads yml' do
        dir = Dir.mktmpdir
        path = File.join(dir, 'a.yml')

        definition = DiverDown::Definition.new(title: 'a')
        File.write(path, definition.to_h.to_yaml)

        loader = DiverDown::DefinitionLoader.new

        expect(loader.load_file(path)).to eq(definition)
      end

      it 'loads msgpack' do
        dir = Dir.mktmpdir
        path = File.join(dir, 'a.msgpack')

        definition = DiverDown::Definition.new(title: 'a')
        File.write(path, definition.to_h.to_msgpack)

        loader = DiverDown::DefinitionLoader.new

        expect(loader.load_file(path)).to eq(definition)
      end
    end
  end
end
