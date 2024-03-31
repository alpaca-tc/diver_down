# frozen_string_literal: true

module DiverDown
  class DefinitionLoader
    # @param store [DiverDown::DefinitionStore]
    def initialize(store)
      @store = store
    end

    # @param dir [String]
    def load_directory(dir)
      files = ::Dir["#{dir}/**/*.{yml,yaml,msgpack}"]

      files.each do
        load_file(_1)
      end
    end

    # @param path [String]
    def load_file(path)
      definition = case File.extname(path)
                   when '.yaml', '.yml'
                     from_yaml(path)
                   when '.msgpack'
                     from_msgpack(path)
                   else
                     raise ArgumentError, "Unsupported file type: #{path}"
                   end

      @store.set(definition)
    end

    private

    def from_yaml(path)
      hash = YAML.load_file(path)
      DiverDown::Definition.from_hash(hash)
    end

    def from_msgpack(path)
      hash = MessagePack.unpack(File.binread(path))
      DiverDown::Definition.from_hash(hash)
    end
  end
end
