# frozen_string_literal: true

RSpec.describe DiverDown::DefinitionStore do
  describe 'InstanceMethods' do
    describe '#load_directory' do
      it 'loads files' do
        dir = Dir.mktmpdir
        path = File.join(dir, 'a.yaml')

        definition = DiverDown::Definition.new(title: 'a')
        File.write(path, definition.to_h.to_yaml)

        store = DiverDown::DefinitionStore.new
        loader = DiverDown::DefinitionLoader.new(store)

        expect {
          loader.load_directory(dir)
        }.to change(store, :size).by(1)
      end
    end

    describe '#load_file' do
      it 'loads yaml' do
        dir = Dir.mktmpdir
        path = File.join(dir, 'a.yaml')

        definition = DiverDown::Definition.new(title: 'a')
        File.write(path, definition.to_h.to_yaml)

        store = DiverDown::DefinitionStore.new
        loader = DiverDown::DefinitionLoader.new(store)

        expect {
          loader.load_file(path)
        }.to change(store, :size).by(1)
      end

      it 'loads yml' do
        dir = Dir.mktmpdir
        path = File.join(dir, 'a.yml')

        definition = DiverDown::Definition.new(title: 'a')
        File.write(path, definition.to_h.to_yaml)

        store = DiverDown::DefinitionStore.new
        loader = DiverDown::DefinitionLoader.new(store)

        expect {
          loader.load_file(path)
        }.to change(store, :size).by(1)
      end

      it 'loads msgpack' do
        dir = Dir.mktmpdir
        path = File.join(dir, 'a.msgpack')

        definition = DiverDown::Definition.new(title: 'a')
        File.write(path, definition.to_h.to_msgpack)

        store = DiverDown::DefinitionStore.new
        loader = DiverDown::DefinitionLoader.new(store)

        expect {
          loader.load_file(path)
        }.to change(store, :size).by(1)
      end
    end
  end
end
