# frozen_string_literal: true

module DiverDown
  class Web
    class DefinitionLoader
      # @param path [String]
      def load_file(path)
        hash = case File.extname(path)
               when '.yaml', '.yml'
                 from_yaml(path)
               when '.json'
                 from_json(path)
               else
                 raise ArgumentError, "Unsupported file type: #{path}"
               end

        DiverDown::Definition.from_hash(hash)
      end

      private

      def from_json(path)
        JSON.parse(File.read(path))
      end

      def from_yaml(path)
        YAML.load_file(path)
      end
    end
  end
end
