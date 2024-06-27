# frozen_string_literal: true

module DiverDown
  class Web
    class Metadata
      class SourceMetadata
        BLANK_MEMO = ''
        BLANK_RE = /\A\s*\z/
        private_constant(:BLANK_MEMO)
        private_constant(:BLANK_RE)

        attr_reader :memo, :module

        # @param source_name [String]
        # NOTE: `module` is a reserved keyword in Ruby
        def initialize(memo: BLANK_MEMO, modulee: nil)
          @memo = memo
          @module = modulee
        end

        # @param memo [String]
        # @return [void]
        def memo=(memo)
          @memo = memo.strip
        end

        # @param modulee [String, nil]
        # @return [void]
        def module=(modulee)
          @module = if modulee.nil? || BLANK_RE.match?(modulee)
                      nil
                    else
                      modulee.strip
                    end
        end

        # @return [Boolean]
        def module?
          !@module.nil?
        end

        # @return [Hash]
        def to_h
          hash = {}

          hash[:memo] = memo unless memo == BLANK_MEMO
          hash[:module] = @module unless @module.nil?

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
