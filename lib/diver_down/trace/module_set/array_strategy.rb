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
            mod = if DiverDown::Helper.module?(_1)
                    _1
                  else
                    # constantize if it is a string
                    DiverDown::Helper.constantize(_1)
                  end

            self[mod] = true
          end
        end

        # @param [Module] mod
        # @return [Boolean, nil]
        def [](mod)
          @set[mod]
        end

        # @param [Module] mod
        # @param value [Boolean]
        # @return [void]
        def []=(mod, value)
          @set[mod] = value
        end
      end
    end
  end
end
