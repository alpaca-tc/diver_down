# frozen_string_literal: true

module DiverDown
  class Web
    class Metadata
      class SourceMetadata
        BLANK_MEMO = ''
        BLANK_RE = /\A\s*\z/
        BLANK_ARRAY = [].freeze
        private_constant(:BLANK_MEMO)
        private_constant(:BLANK_RE)
        private_constant(:BLANK_ARRAY)

        attr_reader :memo, :modules

        # @param source_name [String]
        def initialize(memo: BLANK_MEMO, modules: BLANK_ARRAY)
          @memo = memo
          @modules = modules
        end

        # @param memo [String]
        # @return [void]
        def memo=(memo)
          @memo = memo.strip
        end

        # @param module_names [Array<String>]
        # @return [void]
        def modules=(module_names)
          @modules = module_names.reject do
            BLANK_RE.match?(_1)
          end.freeze
        end

        # @return [Boolean]
        def modules?
          @modules.any?
        end

        # @return [Hash]
        def to_h
          hash = {}

          hash[:memo] = memo unless memo == BLANK_MEMO
          hash[:modules] = modules unless modules.empty?

          hash
        end

        private

        def by_source_name(source_name)
          @store[source_name] ||= {}
        end
      end
    end
  end
end
