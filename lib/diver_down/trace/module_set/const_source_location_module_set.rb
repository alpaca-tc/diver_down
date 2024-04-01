# frozen_string_literal: true

module DiverDown
  module Trace
    class ModuleSet
      class ConstSourceLocationModuleSet
        # @param [Array<String>, Set<String>] paths
        def initialize(paths: [])
          @paths = paths.to_set
        end

        # @param [Module] mod
        # @return [Boolean]
        def include?(mod)
          module_name = DiverDown::Helper.normalize_module_name(mod)

          path, = begin
            Object.const_source_location(module_name)
          rescue NameError, TypeError
            nil
          end

          path && @paths.include?(path)
        end
      end
    end
  end
end
