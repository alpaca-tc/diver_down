# frozen_string_literal: true

module DiverDown
  class Web
    class Metadata
      require 'diver_down/web/metadata/source_metadata'

      # @param path [String]
      def initialize(path)
        @path = path
        load
      end

      # @param source_name [String]
      # @return [DiverDown::Web::Metadata::SourceMetadata]
      def source(source_name)
        @source_map[source_name]
      end

      # @return [Hash]
      def to_h
        source_names = @source_map.keys.sort
        sources = source_names.to_h { [_1, source(_1).to_h] }

        {
          sources:,
        }
      end

      # Write store to file
      # @return [void]
      def flush
        File.write(@path, to_h.to_yaml)
      end

      private

      def load
        @source_map = Hash.new { |h, source_name| h[source_name] = DiverDown::Web::Metadata::SourceMetadata.new }

        begin
          loaded = YAML.load_file(@path)

          return if loaded.nil?

          # NOTE: This is for backward compatibility. It will be removed in the future.
          sources = loaded[:sources] || loaded

          sources.each do |source_name, source_hash|
            @source_map[source_name].memo = source_hash[:memo] if source_hash[:memo]
            @source_map[source_name].modules = source_hash[:modules] if source_hash[:modules]
          end
        rescue StandardError
          # Ignore error
        end
      end
    end
  end
end
