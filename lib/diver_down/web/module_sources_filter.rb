# frozen_string_literal: true

module DiverDown
  class Web
    class ModuleSourcesFilter
      # @param metadata_alias [DiverDown::Web::Metadata]
      def initialize(metadata)
        @metadata = metadata
      end

      # @param definition [DiverDown::Definition]
      # @param modules [Array<Array<String>>]
      # @return [DiverDown::Definition]
      def filter(definition, modulee:)
        new_definition = DiverDown::Definition.new(
          definition_group: definition.definition_group,
          title: definition.title
        )

        match_module = ->(source_name) do
          @metadata.source(source_name).module == modulee
        end

        definition.sources.each do |source|
          next unless match_module.call(source.source_name)

          new_source = new_definition.find_or_build_source(source.source_name)

          source.dependencies.each do |dependency|
            next unless match_module.call(dependency.source_name)

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
