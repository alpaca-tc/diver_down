# frozen_string_literal: true

module DiverDown
  module Trace
    class ModuleSet
      class ConstSourceLocationStrategy < BaseStrategy
        # @param [Array<Module, String>, Set<Module, String>] include
        # @param [Array<Module, String>, Set<Module, String>] exclude
        def initialize(include: [], exclude: [])
          super()

          @cache = {}

          @include = include.to_set
          @exclude = exclude.to_set
        end

        # @param [Module, String] mod
        # @return [Boolean, nil]
        def [](mod)
          unless @cache.key?(mod)
            module_name = DiverDown::Helper.normalize_module_name(mod)

            path, = begin
              Object.const_source_location(module_name)
            rescue NameError, TypeError
              nil
            end

            @cache[mod] = @include.include?(path) && !@exclude.include?(path)
          end

          @cache.fetch(mod)
        end

        # @param [Module] mod
        def []=(mod, value)
          @set[mod] = value
        end
      end
    end
  end
end
