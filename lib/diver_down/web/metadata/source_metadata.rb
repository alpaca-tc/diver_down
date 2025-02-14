# frozen_string_literal: true

module DiverDown
  class Web
    class Metadata
      class SourceMetadata
        BLANK_MEMO = ''
        BLANK_RE = /\A\s*\z/
        private_constant(:BLANK_MEMO)
        private_constant(:BLANK_RE)

        DEPENDENCY_TYPES = %w[valid invalid todo].freeze

        attr_reader :memo, :module, :dependency_types

        # @param source_name [String]
        # NOTE: `module` is a reserved keyword in Ruby
        def initialize(memo: BLANK_MEMO, modulee: nil, dependency_types: {})
          @memo = memo
          @module = modulee
          @dependency_types = dependency_types
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

        # @param to_source [String]
        # @return [String, nil]
        def dependency_type(to_source)
          @dependency_types[to_source]
        end

        # @param dependency_types [Hash]
        # @return [void]
        def dependency_types=(dependency_types)
          @dependency_types.clear

          dependency_types.each do |to_source, dependency_type|
            update_dependency_type(to_source, dependency_type)
          end
        end

        # @param to_source [String]
        # @param dependency_type [String]
        # @return [void]
        def update_dependency_type(to_source, dependency_type)
          if dependency_type.to_s.empty?
            @dependency_types.delete(to_source)
          else
            raise ArgumentError, "invalid dependency_type: #{dependency_type}" unless DEPENDENCY_TYPES.include?(dependency_type)

            @dependency_types[to_source] = dependency_type
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
          hash[:dependency_types] = @dependency_types unless @dependency_types.empty?

          hash
        end
      end
    end
  end
end
