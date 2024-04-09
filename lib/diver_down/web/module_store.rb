# frozen_string_literal: true

require 'yaml'

module DiverDown
  class Web
    class ModuleStore
      BLANK_ARRAY = [].freeze

      def initialize(path)
        @path = path
        @store = load
      end

      # @param source_name [String]
      # @param modules [Array<DiverDown::Web::Modulee>]
      def set(source_name, modules)
        @store[source_name] = modules.dup.freeze
      end

      # @param source_name [String]
      # @return [Array<Module>]
      def get(source_name)
        @store[source_name] || BLANK_ARRAY
      end

      # @return [Hash]
      def to_h
        @store.dup
      end

      # Write store to file
      # @return [void]
      def flush
        File.write(@path, to_h.to_yaml)
      end

      private

      def load
        store = {}

        begin
          loaded = YAML.load_file(@path)
          store.merge!(loaded) if loaded
        rescue StandardError
          # Ignore error
        end

        store
      end
    end
  end
end
