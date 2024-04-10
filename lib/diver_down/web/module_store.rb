# frozen_string_literal: true

require 'yaml'

module DiverDown
  class Web
    class ModuleStore
      BLANK_ARRAY = [].freeze
      BLANK_RE = /\A\s*\z/

      private_constant(:BLANK_RE)

      def initialize(path)
        @path = path
        @store = load
      end

      # @param source_name [String]
      # @param module_names [Array<String>]
      def set(source_name, module_names)
        @store[source_name] = module_names.dup.reject do
          BLANK_RE.match?(_1)
        end.freeze
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
