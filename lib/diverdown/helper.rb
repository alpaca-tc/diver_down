# frozen_string_literal: true

module Diverdown
  module Helper
    CLASS_NAME_QUERY = Module.method(:name).unbind.freeze

    INSTANCE_CLASS_QUERY = Class.instance_method(:class).freeze
    private_constant :INSTANCE_CLASS_QUERY

    # @param obj [Object, String, Module, Class]
    # @return [String, nil] if obj is anonymous module, return nil
    def self.normalize_module_name(obj)
      if String === obj
        obj
      else
        mod = resolve_module(obj)

        # Do not call the original method as much as possible
        CLASS_NAME_QUERY.bind(mod).call ||
          (mod.name if mod.respond_to?(:name))
      end
    end

    # @note The object passed as an argument may be a Proxied BasicObject.
    # For example, the DSL of FactoryBot's factory will add a new method in response to the invoked method name,
    # so passed as an argument methods are not called within this method.
    #
    # @return [Module, Class]
    def self.resolve_module(obj)
      if module?(obj) # Do not call method of this
        resolve_singleton_class(obj)
      else
        k = INSTANCE_CLASS_QUERY.bind(obj).call
        resolve_singleton_class(k)
      end
    end

    # @param obj [Module, Class]
    # @return [Module, Class]
    def self.resolve_singleton_class(obj)
      if obj.singleton_class?
        obj.attached_object
      else
        obj
      end
    end

    # @param obj [Object, Module, Class]
    # @return ['instance', 'class']
    def self.module?(obj)
      Module === obj
    end

    # @param str [String]
    # @return [Module]
    def self.constantize(str)
      ::ActiveSupport::Inflector.constantize(str)
    end
  end
end
