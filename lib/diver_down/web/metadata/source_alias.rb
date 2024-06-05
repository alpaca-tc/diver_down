# frozen_string_literal: true

module DiverDown
  class Web
    class Metadata
      class SourceAlias
        class ConflictError < StandardError
          attr_reader :alias_name, :conflicted_alias_name, :source_names

          def initialize(alias_name, conflicted_alias_name, source_name)
            @alias_name = alias_name
            @conflicted_alias_name = conflicted_alias_name
            @source_name = source_name

            super("Alias '#{alias_name}' conflicts with '#{conflicted_alias_name}' for '#{source_name}'")
          end
        end

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
            prev_source_names&.each do |prev_source_name|
              @source_name_to_alias.delete(prev_source_name)
            end
          else
            check_conflict(alias_name, source_names)
            @alias_to_source_names[alias_name] = source_names.sort

            source_names.each do |source_name|
              @source_name_to_alias[source_name] = alias_name
            end
          end
        end

        # @param alias_name [String]
        # @return [String]
        def resolve_alias(source_name)
          @source_name_to_alias[source_name] if @source_name_to_alias.key?(source_name)
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

        private

        def check_conflict(alias_name, source_names)
          source_names.each do |source_name|
            resolved_source_name = resolve_alias(source_name)
            next if resolved_source_name.nil? # not aliased
            next if resolved_source_name == alias_name # for update

            raise ConflictError.new(alias_name, resolved_source_name, source_name)
          end
        end
      end
    end
  end
end
