# frozen_string_literal: true

module DiverDown
  module Trace
    # Tracepoint traces only ruby-lang calls because tracing c-lang calls is very slow.
    # In this case, methods such as new will not be traceable under normal circumstances, so at a minimum, redefine them in ruby and hack them so that they can be traced.
    #
    # Do not use this in a production environment.
    module RedefineRubyMethods
      DEFAULT_METHODS = {
        Module => {
          singleton: %i[name],
          instance: [],
        },
        Class => {
          singleton: %i[name allocate new],
          instance: [],
        },
      }.freeze

      class RubyMethods < Module
        # @param class_method_names [Array<Symbol>]
        # @param instance_method_names [Array<Symbol>]
        def initialize(class_method_names, instance_method_names)
          unless class_method_names.empty?
            def_class_methods = class_method_names.inject(+'') do |buf, method_name|
              buf << <<~METHOD
                def #{method_name}(...)
                  super
                end

              METHOD
            end

            mod = Module.new
            mod.module_eval(def_class_methods, __FILE__, __LINE__)
            const_set(:CLASS_METHODS, mod)
          end

          unless instance_method_names.empty?
            instance_method_names.inject(+'') do |_buf, method_name|
              define_method(method_name) do |*_args, **_options|
                super
              end
            end
          end
        end

        # @param base [Module]
        def prepend_features(base)
          base.singleton_class.prepend(const_get(:CLASS_METHODS)) if const_defined?(:CLASS_METHODS)
          super
        end
      end

      # @param map [Hash{ Class => Hash{ singleton: Array<String>, instance: Array<String> } }]
      def self.redefine_c_methods(map = DEFAULT_METHODS)
        map.each do |m, method_names|
          m.prepend(RubyMethods.new(method_names[:singleton], method_names[:instance]))
        end
      end
    end
  end
end
