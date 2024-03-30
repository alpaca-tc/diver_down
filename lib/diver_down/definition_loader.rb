# frozen_string_literal: true

module DiverDown
  class DefinitionLoader
    # @param store [DiverDown::DefinitionStore]
    def initialize(store)
      @store = store
    end

    # @param path [String]
    def load_file(path)
      case File.extname(path)
      when '.yaml', '.yml'
        load_yaml(path)
      when '.msgpack'
        load_msgpack(path)
      else
        raise ArgumentError, "Unsupported file type: #{path}"
      end
    end

    private

    def load_yaml(path)
      hash = DiverDown::Helper.deep_symbolize_keys(YAML.load_file(path))
      load_hash(hash)
    end

    def load_msgpack(path)
      hash = DiverDown::Helper.deep_symbolize_keys(MessagePack.unpack(File.binread(path)))
      load_hash(hash)
    end

    def load_hash(hash)
      definition = DiverDown::Definition.from_hash(hash)
      @store.set(definition)
    end
  end
end
