# frozen_string_literal: true

require 'active_support/inflector'

module Diverdown
  module RSpec
    require 'diverdown/rspec/tracer'
    require 'diverdown/rspec/call_stack'
    require 'diverdown/rspec/module_set'
    require 'diverdown/rspec/redefine_ruby_methods'

    @trace_events = %i[
      call c_call return c_return
    ]

    # Trace only Ruby-implemented methods because tracing C-implemented methods is very slow
    # Override Ruby only with the minimal set of methods needed to trace dependencies.
    #
    # @return [void]
    def self.trace_only_ruby_world!(map = Diverdown::RSpec::RedefineRubyMethods::DEFAULT_METHODS)
      Diverdown::RSpec::Tracer.trace_events = %i[call return]
      Diverdown::RSpec::RedefineRubyMethods.redefine_c_methods(map)
    end
  end
end
