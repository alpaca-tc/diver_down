# frozen_string_literal: true

module DiverDown
  class Web
    class Metadata
      class SourceAlias
        BLANK_RE = /\A\s*\z/

        def initialize
          # Hash{ alias_name => Set<source_name, ...> }
          @alias_to_source_names = {}
          @source_name_to_alias = {}
        end

        # @param alias_name [String]
        # @param source_names [Array<String>]
        # @return [void]
        def update_alias(alias_name, source_names)
          source_names = source_names.reject { BLANK_RE.match?(_1) }

          if source_names.empty?
            prev_source_names = @alias_to_source_names.delete(alias_name)
            prev_source_names.each do |prev_source_name|
              @source_name_to_alias.delete(prev_source_name)
            end
          else
            @alias_to_source_names[alias_name] = source_names.sort

            source_names.each do |source_name|
              @source_name_to_alias[source_name] = alias_name
            end
          end
        end

        # @param alias_name [String]
        # @return [String]
        def resolve_alias(source_name)
          if @source_name_to_alias.key?(source_name)
            @source_name_to_alias[source_name]
          else
            source_name
          end
        end

        # @param alias_name [String]
        # @return [Array<String>]
        def aliased_source_names(alias_name)
          @alias_to_source_names[alias_name] if @alias_to_source_names.key?(alias_name)
        end

        # @return [Hash]
        def to_h
          keys = @alias_to_source_names.keys.sort
          keys.to_h { [_1, aliased_source_names(_1)] }
        end
      end
    end
  end
end
