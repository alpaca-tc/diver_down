# frozen_string_literal: true

module DiverDown
  module Trace
    # A class to quickly determine if a TracePoint is a module to be traced.
    class ModuleSet
      require 'diver_down/trace/module_set/array_module_set'
      require 'diver_down/trace/module_set/const_source_location_module_set'

      # @param [Array<Module, String>, Set<Module, String>, nil] modules
      # @param [Array<String>] include
      def initialize(modules: nil, include: nil)
        @cache = {}
        @array_module_set = DiverDown::Trace::ModuleSet::ArrayModuleSet.new(modules) unless modules.nil?
        @const_source_location_module_set = DiverDown::Trace::ModuleSet::ConstSourceLocationModuleSet.new(include:) unless include.nil?
      end

      # @param [Module] mod
      # @return [Boolean]
      def include?(mod)
        unless @cache.key?(mod)
          if DiverDown::Helper.class?(mod)
            # class
            begin
              dig_superclass(mod)
            rescue TypeError => e
              # https://github.com/ruby/ruby/blob/f42164e03700469a7000b4f00148a8ca01d75044/object.c#L2232
              return false if e.message == 'uninitialized class'

              raise
            end
          else
            # module
            @cache[mod] = !!_include?(mod)
          end
        end

        @cache.fetch(mod)
      end

      private

      def _include?(mod)
        @array_module_set&.include?(mod) ||
          @const_source_location_module_set&.include?(mod)
      end

      def dig_superclass(mod)
        stack = []
        current = mod
        included = nil

        until current.nil?
          if @cache.key?(current)
            included = @cache.fetch(current)
            break
          else
            stack.push(current)
            included = _include?(current)

            break if included

            current = current.superclass
          end
        end

        # Convert nil to boolean
        included = !!included

        stack.each do
          @cache[_1] = included unless @cache.key?(_1)
        end
      end
    end
  end
end
