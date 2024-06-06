# frozen_string_literal: true

module DiverDown
  class Web
    class Metadata
      class SourceAlias
        class ConflictError < StandardError
          attr_reader :source_name

          def initialize(message, source_name:)
            @source_name = source_name

            super(message)
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

        # Rollback the changes made in the block if an conflict error occurs.
        #
        # @raise [ConflictError]
        def transaction
          alias_to_source_names = deep_dup(@alias_to_source_names)
          source_name_to_alias = deep_dup(@source_name_to_alias)

          yield
        rescue ConflictError
          @alias_to_source_names = alias_to_source_names
          @source_name_to_alias = source_name_to_alias

          raise
        end

        # @return [Hash]
        def to_h
          keys = @alias_to_source_names.keys.sort
          keys.to_h { [_1, aliased_source_names(_1)] }
        end

        private

        def deep_dup(hash)
          hash.transform_values do
            if _1.is_a?(Hash)
              deep_dup(_1)
            else
              _1.dup
            end
          end
        end

        def added_source_names(excluding_alias_name)
          source_names = Set.new

          @alias_to_source_names.each_key do |name|
            next if excluding_alias_name == name

            source_names.add(name)

            @alias_to_source_names[name].each do |source_name|
              source_names.add(source_name)
            end
          end

          source_names
        end

        def check_conflict(alias_name, source_names)
          if source_names.any? { _1 == alias_name }
            raise(ConflictError.new("Cannot create an alias for '#{alias_name}' that refers to itself.", source_name: alias_name))
          end

          registered_source_names = added_source_names(alias_name)

          if registered_source_names.include?(alias_name)
            raise ConflictError.new("Alias '#{alias_name}' is already aliased.", source_name: alias_name)
          end

          conflicted_source_name = source_names.find { registered_source_names.include?(_1) }

          if conflicted_source_name
            resolved_source_name = resolve_alias(conflicted_source_name)
            raise ConflictError.new("Source '#{conflicted_source_name}' is already aliased to '#{resolved_source_name}'.", source_name: conflicted_source_name)
          end
        end
      end
    end
  end
end
