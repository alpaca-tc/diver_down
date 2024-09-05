# frozen_string_literal: true

module DiverDown
  module Trace
    class IgnoredMethodIds
      VALID_VALUE = %i[
        single
        all
      ].freeze

      def initialize(ignored_methods)
        # Ignore all methods in the module
        # Hash{ Module => Symbol }
        @ignored_modules = {}

        # Ignore all methods in the class
        # Hash{ Module => Hash{ Symbol => Symbol } }
        @ignored_class_method_id = Hash.new { |h, k| h[k] = {} }

        # Ignore all methods in the instance
        # Hash{ Module => Hash{ Symbol => Symbol } }
        @ignored_instance_method_id = Hash.new { |h, k| h[k] = {} }

        ignored_methods.each do |ignored_method, value|
          raise ArgumentError, "Invalid value: #{value}. valid values are #{VALID_VALUE}" unless VALID_VALUE.include?(value)

          if ignored_method.include?('.')
            # instance method
            class_name, method_id = ignored_method.split('.')
            mod = DiverDown::Helper.constantize(class_name)
            @ignored_class_method_id[mod][method_id.to_sym] = value
          elsif ignored_method.include?('#')
            # class method
            class_name, method_id = ignored_method.split('#')
            mod = DiverDown::Helper.constantize(class_name)
            @ignored_instance_method_id[mod][method_id.to_sym] = value
          else
            # module
            mod = DiverDown::Helper.constantize(ignored_method)
            @ignored_modules[mod] = value
          end
        end
      end

      # @param mod [Module]
      # @param is_class [Boolean] class is true, instance is false
      # @param method_id [Symbol]
      # @return [Symbol, false] VALID_VALUE
      def ignored(mod, is_class, method_id)
        ignored_module(mod) || ignored_method(mod, is_class, method_id)
      end

      private

      def ignored_module(mod)
        unless @ignored_modules.key?(mod)
          dig_superclass(mod)
        end

        @ignored_modules.fetch(mod)
      end

      def ignored_method(mod, is_class, method_id)
        store = if is_class
                  # class methods
                  @ignored_class_method_id
                else
                  # instance methods
                  @ignored_instance_method_id
                end

        begin
          dig_superclass_method_id(store, mod, method_id) unless store[mod].key?(method_id)
        rescue TypeError => e
          # https://github.com/ruby/ruby/blob/f42164e03700469a7000b4f00148a8ca01d75044/object.c#L2232
          return false if e.message == 'uninitialized class'

          raise
        end

        store.fetch(mod).fetch(method_id)
      end

      def dig_superclass(mod)
        unless DiverDown::Helper.class?(mod)
          # NOTE: Do not lookup the ancestors if module given because of the complexity of implementation
          @ignored_modules[mod] = false
          return
        end

        stack = []
        current = mod
        ignored = nil

        until current.nil?
          if @ignored_modules.key?(current)
            ignored = @ignored_modules.fetch(current)
            break
          else
            stack.push(current)
            current = current.superclass
          end
        end

        # Convert nil to boolean
        stack.each do
          @ignored_modules[_1] = ignored || false
        end
      end

      def dig_superclass_method_id(store, mod, method_id)
        unless DiverDown::Helper.class?(mod)
          # NOTE: Do not lookup the ancestors if module given because of the complexity of implementation
          store[mod][method_id] = false
          return
        end

        stack = []
        current = mod
        ignored = nil

        until current.nil?
          if store[current].key?(method_id)
            ignored = store[current].fetch(method_id)
            break
          else
            stack.push(current)
            current = current.superclass
          end
        end

        # Convert nil to boolean
        stack.each do
          store[_1][method_id] = ignored || false
        end
      end
    end
  end
end
