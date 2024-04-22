# frozen_string_literal: true

module DiverDown
  module Helper
    CLASS_NAME_QUERY = Module.method(:name).unbind.freeze

    INSTANCE_CLASS_QUERY = Class.instance_method(:class).freeze
    private_constant :INSTANCE_CLASS_QUERY

    # @param mod [Module]
    # @return [String, nil] if mod is anonymous module, return nil
    def self.normalize_module_name(mod)
      resolved_mod = resolve_module(mod)

      # Do not call the original method as much as possible
      CLASS_NAME_QUERY.bind_call(resolved_mod) ||
        (resolved_mod.name if resolved_mod.respond_to?(:name))
    end

    # @param str [String]
    # @return [Module]
    def self.constantize(str)
      ::ActiveSupport::Inflector.constantize(str)
    end
  end
end
