# frozen_string_literal: true

require 'active_support/inflector'

module DiverDown
  module Trace
    require 'diver_down/trace/tracer'
    require 'diver_down/trace/tracer/session'
    require 'diver_down/trace/call_stack'
    require 'diver_down/trace/module_set'
    require 'diver_down/trace/redefine_ruby_methods'
    require 'diver_down/trace/ignored_method_ids'

    @trace_events = %i[
      call c_call return c_return
    ]

    # Trace only Ruby-implemented methods because tracing C-implemented methods is very slow
    # Override Ruby only with the minimal set of methods needed to trace dependencies.
    #
    # @return [void]
    def self.trace_only_ruby_world!(map = DiverDown::Trace::RedefineRubyMethods::DEFAULT_METHODS)
      DiverDown::Trace::Tracer.trace_events = %i[call return]
      DiverDown::Trace::RedefineRubyMethods.redefine_c_methods(map)
    end
  end
end
