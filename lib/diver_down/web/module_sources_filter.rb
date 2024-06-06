# frozen_string_literal: true

module DiverDown
  class Web
    class ModuleSourcesFilter
      # @param metadata_alias [DiverDown::Web::Metadata]
      def initialize(metadata)
        @metadata = metadata
      end

      # @param definition [DiverDown::Definition]
      # @param match_modules [Array<Array<String>>]
      # @return [DiverDown::Definition]
      def filter(definition, match_modules:)
        new_definition = DiverDown::Definition.new(
          definition_group: definition.definition_group,
          title: definition.title
        )

        is_match_modules = ->(source_name) do
          source_modules = @metadata.source(source_name).modules

          match_modules.any? do |modules|
            source_modules.first(modules.size) == modules
          end
        end

        definition.sources.each do |source|
          next unless is_match_modules.call(source.source_name)

          new_source = new_definition.find_or_build_source(source.source_name)

          source.dependencies.each do |dependency|
            next unless is_match_modules.call(dependency.source_name)

            new_dependency = new_source.find_or_build_dependency(dependency.source_name)

            next unless new_dependency

            dependency.method_ids.each do |method_id|
              new_method_id = new_dependency.find_or_build_method_id(
                context: method_id.context,
                name: method_id.name
              )

              method_id.paths.each do |path|
                new_method_id.add_path(path)
              end
            end
          end
        end

        new_definition
      end
    end
  end
end
