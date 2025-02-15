# frozen_string_literal: true

module DiverDown
  class Web
    class DefinitionModuleDependencies
      class ModuleDependency
        attr_accessor :module
        attr_reader :module_dependencies, :module_reverse_dependencies, :source_map, :source_reverse_dependency_map

        def initialize(modulee)
          @module = modulee
          @module_dependencies = Set.new
          @module_reverse_dependencies = Set.new
          @source_map = {}
          @source_reverse_dependency_map = {}
        end

        # @return [Array<Source>]
        def sources
          @source_map.keys.sort.map { @source_map.fetch(_1) }
        end

        # @return [Array<Source>]
        def source_reverse_dependencies
          @source_reverse_dependency_map.keys.sort.map { @source_reverse_dependency_map.fetch(_1) }
        end
      end

      def initialize(metadata, definition)
        @metadata = metadata
        @definition = definition
      end

      # @return [Hash{ String => Hash{ String => Array<DiverDown::Definition::Source> } }]
      def build_module_dependency_map
        module_dependency_map = Hash.new { |h, k| h[k] = ModuleDependency.new(k) }

        @definition.sources.each do |source|
          source_module = @metadata.source(source.source_name).module
          next if source_module.nil?

          source_module_dependency = module_dependency_map[source_module]
          source_module_dependency.source_map[source.source_name] ||= DiverDown::Definition::Source.new(source_name: source.source_name)

          source.dependencies.each do |dependency|
            dependency_module = @metadata.source(dependency.source_name).module

            next if source_module == dependency_module
            next if dependency_module.nil?

            dependency_module_dependency = module_dependency_map[dependency_module]

            # Add module dependencies
            source_module_dependency.module_dependencies.add(dependency_module)

            # Add module reverse dependencies
            dependency_module_dependency.module_reverse_dependencies.add(source_module)

            # Add source
            definition_source = source_module_dependency.source_map[source.source_name]
            definition_dependency = definition_source.find_or_build_dependency(dependency.source_name)
            dependency.method_ids.each do |method_id|
              definition_dependency.find_or_build_method_id(name: method_id.name, context: method_id.context).add_path(*method_id.paths)
            end

            # Add source reverse dependencies
            # NOTE: Reverse dependencies's method_ids are not added because they are difficult to understand and not used.
            definition_source = dependency_module_dependency.source_reverse_dependency_map[source.source_name] ||= DiverDown::Definition::Source.new(source_name: source.source_name)
            definition_source.find_or_build_dependency(dependency.source_name)
          end
        end

        module_dependency_map
      end
    end
  end
end
