# frozen_string_literal: true

require 'yaml'

module DiverDown
  class Web
    class ModuleStore
      BLANK_ARRAY = [].freeze
      BLANK_MEMO = ''
      BLANK_RE = /\A\s*\z/

      private_constant(:BLANK_RE)

      def initialize(path)
        @path = path
        @store = load
      end

      # @param source_name [String]
      # @param module_names [Array<String>]
      def set_modules(source_name, module_names)
        source = (@store[source_name] ||= {})

        source[:modules] = module_names.dup.reject do
          BLANK_RE.match?(_1)
        end.freeze
      end

      # @param source_name [String]
      # @return [Array<Module>]
      def get_modules(source_name)
        return BLANK_ARRAY unless @store.key?(source_name)

        @store[source_name][:modules] || BLANK_ARRAY
      end

      # @param source_name [String]
      # @param memo [String]
      # @return [void]
      def set_memo(source_name, memo)
        source = (@store[source_name] ||= {})
        source[:memo] = memo.strip
      end

      # @param source_name [String]
      # @return [String]
      def get_memo(source_name)
        return BLANK_MEMO unless @store.key?(source_name)

        @store[source_name][:memo] || BLANK_MEMO
      end

      # @param source_name [String]
      # @return [Boolean]
      def classified?(source_name)
        get_modules(source_name).any?
      end

      # @return [Hash]
      def to_h
        sorted_store = {}

        @store.keys.sort.each do |key|
          sorted_store[key] = @store[key]
        end

        sorted_store
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
