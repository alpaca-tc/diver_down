# frozen_string_literal: true

module DiverDown
  module Trace
    class ModuleSet
      class ArrayStrategy < BaseStrategy
        # @param [Array<Module, String>, #each] modules
        def initialize(modules)
          super()

          @set = {}

          modules.each do
            self[_1] = true
          end
        end

        # @param [Module, String] mod_or_module_name
        # @return [Boolean, nil]
        def [](mod_or_module_name)
          @set[mod_or_module_name]
        end

        # @param [Module, String] mod_or_module_name
        # @param value [Boolean]
        # @return [void]
        def []=(mod_or_module_name, value)
          @set[mod_or_module_name] = value

          if DiverDown::Helper.module?(mod_or_module_name)
            @set[normalize_module_name(mod_or_module_name)] = value
          else
            @set[constantize(mod_or_module_name)] = value
          end
        end
      end
    end
  end
end
