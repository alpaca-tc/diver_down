# frozen_string_literal: true

RSpec.describe DiverDown::Web::DefinitionStore do
  describe 'InstanceMethods' do
    describe '#load_file' do
      it 'loads yaml' do
        dir = Dir.mktmpdir
        path = File.join(dir, 'a.yaml')

        definition = DiverDown::Definition.new(title: 'a')
        File.write(path, definition.to_h.to_yaml)

        loader = DiverDown::Web::DefinitionLoader.new

        expect(loader.load_file(path)).to eq(definition)
      end

      it 'loads yml' do
        dir = Dir.mktmpdir
        path = File.join(dir, 'a.yml')

        definition = DiverDown::Definition.new(title: 'a')
        File.write(path, definition.to_h.to_yaml)

        loader = DiverDown::Web::DefinitionLoader.new

        expect(loader.load_file(path)).to eq(definition)
      end

      it 'loads json' do
        dir = Dir.mktmpdir
        path = File.join(dir, 'a.json')

        definition = DiverDown::Definition.new(title: 'a')
        File.write(path, JSON.dump(definition.to_h))

        loader = DiverDown::Web::DefinitionLoader.new

        expect(loader.load_file(path)).to eq(definition)
      end
    end
  end
end
