# frozen_string_literal: true

module DiverDown
  module Trace
    class ModuleSet
      class BaseStrategy
        # @param [Module, String] mod_or_module_name
        # @return [Boolean, nil] nil means mod_or_module_name is not stored yet
        def [](mod_or_module_name)
          raise NotImplementedError, '[] must be implemented in subclass'
        end

        # @param [Module, String] mod_or_module_name
        # @param [Boolean] value
        def []=(mod_or_module_name, value)
          raise NotImplementedError, '[] must be implemented in subclass'
        end
      end
    end
  end
end
