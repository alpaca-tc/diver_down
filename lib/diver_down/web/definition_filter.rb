# frozen_string_literal: true

module DiverDown
  class Web
    class DefinitionFilter
      # @param metadata_alias [DiverDown::Web::Metadata]
      # @param focus_modules [Array<String>]
      # @param modules [Array<String>]
      # @param remove_internal_sources [Boolean]
      def initialize(metadata, focus_modules: [], modules: [], remove_internal_sources: false)
        @metadata = metadata
        @focus_modules = focus_modules
        @modules = modules | focus_modules
        @remove_internal_sources = remove_internal_sources
      end

      # @param definition [DiverDown::Definition]
      # @return [DiverDown::Definition]
      def filter(definition)
        return definition if !@remove_internal_sources && @modules.empty?

        new_definition = DiverDown::Definition.new(
          definition_group: definition.definition_group,
          title: definition.title
        )

        source_names = extract_match_source_names(definition.sources)

        definition.sources.each do |source|
          next unless source_names.include?(source.source_name)

          new_source = new_definition.find_or_build_source(source.source_name)

          source.dependencies.each do |dependency|
            next unless source_names.include?(dependency.source_name)
            next unless focus_module?(source, dependency)
            next if @remove_internal_sources && @metadata.source(source.source_name).module == @metadata.source(dependency.source_name).module

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

      private

      def focus_module?(source, dependency)
        return true if @focus_modules.empty?
        return true if @focus_modules.include?(@metadata.source(source.source_name).module)
        return true if @focus_modules.include?(@metadata.source(dependency.source_name).module)

        false
      end

      def extract_match_source_names(sources)
        # Filter sources by modules.
        source_names = sources.filter_map do |source|
          source.source_name if match_module?(source.source_name)
        end.to_set

        if @remove_internal_sources
          # Remove internal sources.
          external_called_sources = Set.new

          sources.each do |source|
            next unless source_names.include?(source.source_name)

            source_module = @metadata.source(source.source_name).module

            source.dependencies.each do |dependency|
              next unless source_names.include?(dependency.source_name)

              dependency_module = @metadata.source(dependency.source_name).module

              next if source_module == dependency_module

              external_called_sources << source.source_name
              external_called_sources << dependency.source_name
              break
            end
          end

          external_called_sources
        else
          source_names
        end
      end

      def top_module(source_name)
        @metadata.source(source_name).modules.first
      end

      def match_module?(source_name)
        @modules.empty? || @modules.include?(@metadata.source(source_name).module)
      end
    end
  end
end
