# frozen_string_literal: true

module DiverDown
  class Web
    class AliasResolver
      # @param metadata_alias [DiverDown::Web::Metadata::SourceAlias]
      def initialize(metadata_alias)
        @metadata_alias = metadata_alias
      end

      # @param definition [DiverDown::Definition]
      # @return [DiverDown::Definition]
      def resolve(definition)
        new_definition = DiverDown::Definition.new(
          definition_group: definition.definition_group,
          title: definition.title,
        )

        definition.sources.each do |source|
          resolved_source_name = @metadata_alias.resolve_alias(source.source_name)
          new_source = new_definition.find_or_build_source(resolved_source_name)

          source.dependencies.each do |dependency|
            resolved_dependency_source_name = @metadata_alias.resolve_alias(dependency.source_name)
            new_dependency = new_source.find_or_build_dependency(resolved_dependency_source_name)

            next unless new_dependency

            dependency.method_ids.each do |method_id|
              new_method_id = new_dependency.find_or_build_method_id(
                context: method_id.context,
                name: method_id.name,
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
