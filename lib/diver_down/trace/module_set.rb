# frozen_string_literal: true

module Diverdown
  module Trace
    # A class to quickly determine if a TracePoint is a module to be traced.
    class ModuleSet
      # @param [Array<Module, String>] modules
      def initialize(modules)
        @set = {}
        @normalized_module_name_cache = {}
        @constantized_cache = {}

        modules.each do
          add(_1, true)
        end
      end

      # @param [Module, String] mod_or_module_name
      # @return [Boolean]
      def include?(mod_or_module_name)
        return @set.fetch(mod_or_module_name) if @set.key?(mod_or_module_name)

        superclass_include(mod_or_module_name)
      end

      private

      def superclass_include(mod)
        return false unless Class === mod

        stack = [mod]
        current = mod.superclass
        found = nil

        while current && found.nil?
          found = @set.fetch(current) if @set.key?(current)
          stack.push(current)
          current = current.superclass
        end

        # Convert nil to boolean
        found = !!found

        stack.each do
          add(_1, found)
        end

        found
      rescue TypeError => e
        # https://github.com/ruby/ruby//blob/f42164e03700469a7000b4f00148a8ca01d75044/object.c#L2232
        return false if e.message == 'uninitialized class'

        raise
      end

      # @param [Module, String] mod_or_module_name
      # @param value [Boolean]
      # @return [void]
      def add(mod_or_module_name, value)
        @set[mod_or_module_name] = value

        if Diverdown::Helper.module?(mod_or_module_name)
          @set[normalize_module_name(mod_or_module_name)] = value
        else
          @set[constantize(mod_or_module_name)] = value
        end
      end

      # @param [String] module_name
      # @return [Module]
      def constantize(module_name)
        @constantized_cache[module_name] ||= Diverdown::Helper.constantize(module_name)
      end

      # @param [Module] mod
      # @return [String]
      def normalize_module_name(mod)
        @normalized_module_name_cache[mod] ||= Diverdown::Helper.normalize_module_name(mod)
      end
    end
  end
end
