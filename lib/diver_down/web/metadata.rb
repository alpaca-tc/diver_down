# frozen_string_literal: true

module DiverDown
  class Web
    class Metadata
      require 'diver_down/web/metadata/source_metadata'
      require 'diver_down/web/metadata/source_alias'

      attr_reader :source_alias

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

        sources = source_names.filter_map {
          h = source(_1).to_h
          [_1, h] unless h.empty?
        }.to_h

        {
          sources:,
          source_alias: @source_alias.to_h,
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
        @source_alias = DiverDown::Web::Metadata::SourceAlias.new

        loaded = YAML.load_file(@path)

        return if loaded.nil?

        # NOTE: This is for backward compatibility. It will be removed in the future.
        (loaded[:sources] || loaded || []).each do |source_name, source_hash|
          source(source_name).memo = source_hash[:memo] if source_hash[:memo]

          if source_hash[:modules].is_a?(Array)
            source(source_name).module = source_hash[:modules][0]
          elsif source_hash[:module]
            source(source_name).module = source_hash[:module]
          end
        end

        loaded[:source_alias]&.each do |alias_name, source_names|
          @source_alias.update_alias(alias_name, source_names)
        end
      end
    end
  end
end
