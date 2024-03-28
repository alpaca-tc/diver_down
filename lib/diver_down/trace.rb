# frozen_string_literal: true

require 'active_support/inflector'

module Diverdown
  module Trace
    require 'diverdown/trace/tracer'
    require 'diverdown/trace/call_stack'
    require 'diverdown/trace/module_set'
    require 'diverdown/trace/redefine_ruby_methods'

    @trace_events = %i[
      call c_call return c_return
    ]

    # Trace only Ruby-implemented methods because tracing C-implemented methods is very slow
    # Override Ruby only with the minimal set of methods needed to trace dependencies.
    #
    # @return [void]
    def self.trace_only_ruby_world!(map = Diverdown::Trace::RedefineRubyMethods::DEFAULT_METHODS)
      Diverdown::Trace::Tracer.trace_events = %i[call return]
      Diverdown::Trace::RedefineRubyMethods.redefine_c_methods(map)
    end
  end
end
