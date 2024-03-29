# frozen_string_literal: true

module DiverDown
  module Trace
    # A class to quickly determine if a TracePoint is a module to be traced.
    class ModuleSet
      require 'diver_down/trace/module_set/base_strategy'
      require 'diver_down/trace/module_set/array_strategy'

      # @param [DiverDown::Trace::ModuleSet::BaseStrategy] strategy
      def initialize(strategy)
        @strategy = strategy
      end

      # @param [Module, String] mod_or_module_name
      # @return [Boolean]
      def include?(mod_or_module_name)
        result = @strategy[mod_or_module_name]

        if result.nil?
          # If the strategy doesn't know, check the superclass
          superclass_include(mod_or_module_name)
        else
          result
        end
      end

      private

      def superclass_include(mod)
        return false unless Class === mod

        stack = [mod]
        current = mod.superclass
        found = nil

        while current && found.nil?
          found = @strategy[current] # nil or boolean
          stack.push(current)
          current = current.superclass
        end

        # Convert nil to boolean
        found = !!found

        stack.each do
          @strategy[_1] = found
        end

        found
      rescue TypeError => e
        # https://github.com/ruby/ruby//blob/f42164e03700469a7000b4f00148a8ca01d75044/object.c#L2232
        return false if e.message == 'uninitialized class'

        raise
      end
    end
  end
end
