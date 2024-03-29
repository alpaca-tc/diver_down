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

        # @param [Module, String] mod_or_module_name
        # @return [Boolean, nil]
        def [](mod_or_module_name)
          unless @cache.key?(mod_or_module_name)
            module_name = if DiverDown::Helper.module?(mod_or_module_name)
                            normalize_module_name(mod_or_module_name)
                          else
                            mod_or_module_name
                          end

            path, _ = begin
                        Object.const_source_location(module_name)
                      rescue NameError
                        nil
                      rescue TypeError
                        binding.irb
                      end

            @cache[mod_or_module_name] = @include.include?(path) && !@exclude.include?(path)
          end

          @cache.fetch(mod_or_module_name)
        end

        # @param [Module, String] mod_or_module_name
        def []=(mod_or_module_name, value)
          @set[mod_or_module_name] = value

          if DiverDown::Helper.module?(mod_or_module_name)
            @set[normalize_module_name(mod_or_module_name)] = value
          else
            @set[constantize(mod_or_module_name)] = value
          end
        end

        private

        def add(set, mod_or_module_name)
          set[mod_or_module_name] = true

          if DiverDown::Helper.module?(mod_or_module_name)
            set[normalize_module_name(mod_or_module_name)] = true
          else
            set[constantize(mod_or_module_name)] = true
          end
        end
      end
    end
  end
end
