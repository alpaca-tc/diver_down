# frozen_string_literal: true

module DiverDown
  module Trace
    class ModuleSet
      class ArrayModuleSet
        # @param [Array<Module, String>, #each] modules
        def initialize(modules)
          @map = {}

          modules.each do
            mod = if DiverDown::Helper.module?(_1)
                    _1
                  else
                    # constantize if it is a string
                    DiverDown::Helper.constantize(_1)
                  end

            @map[mod] = true
          end
        end

        # @param [Module] mod
        # @return [Boolean, nil]
        def include?(mod)
          @map[mod]
        end
      end
    end
  end
end
