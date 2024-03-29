# frozen_string_literal: true

module DiverDown
  module Trace
    class ModuleSet
      class BaseStrategy
        def initialize
          @normalized_module_name_cache = {}
          @constantized_cache = {}
        end

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

        private

        # @param [String] module_name
        # @return [Module]
        def constantize(module_name)
          @constantized_cache[module_name] ||= DiverDown::Helper.constantize(module_name)
        end

        # @param [Module] mod
        # @return [String]
        def normalize_module_name(mod)
          @normalized_module_name_cache[mod] ||= DiverDown::Helper.normalize_module_name(mod)
        end
      end
    end
  end
end
