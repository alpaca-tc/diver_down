# frozen_string_literal: true

module DiverDown
  class DefinitionLoader
    # @param path [String]
    def load_file(path)
      case File.extname(path)
      when '.yaml', '.yml'
        from_yaml(path)
      when '.msgpack'
        from_msgpack(path)
      else
        raise ArgumentError, "Unsupported file type: #{path}"
      end
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
