# frozen_string_literal: true

module DiverDown
  module Trace
    class Tracer
      DEFAULT_TRACE_EVENTS = %i[
        call
        return
        c_call
        c_return
        b_call
        b_return
      ].freeze

      # @return [Array<Symbol>]
      def self.trace_events
        @trace_events || DEFAULT_TRACE_EVENTS
      end

      # @param events [Array<Symbol>]
      class << self
        attr_writer :trace_events
      end

      # @param module_set [DiverDown::Trace::ModuleSet, Array<Module, String>]
      # @param caller_paths [Array<String>, nil] if nil, trace all files
      # @param ignored_method_ids [Hash{ String => Symbol }, nil]
      # @param filter_method_id_path [#call, nil] filter method_id.path
      # @param module_set [DiverDown::Trace::ModuleSet, nil] for optimization
      def initialize(module_set: {}, caller_paths: nil, ignored_method_ids: nil, filter_method_id_path: nil)
        if caller_paths && !caller_paths.all? { Pathname.new(_1).absolute? }
          raise ArgumentError, "caller_paths must be absolute path(#{caller_paths})"
        end

        @module_set = if module_set.is_a?(DiverDown::Trace::ModuleSet)
                        module_set
                      elsif module_set.is_a?(Hash)
                        DiverDown::Trace::ModuleSet.new(**module_set)
                      else
                        raise ArgumentError, <<~MSG
                          Given invalid module_set. #{module_set}"

                          Available types are:

                          Hash{
                            modules: Array<Module, String> | Set<Module, String> | nil
                            paths: Array<String> | Set<String> | nil
                          } | DiverDown::Trace::ModuleSet
                        MSG
                      end

        @ignored_method_ids = if ignored_method_ids.is_a?(DiverDown::Trace::IgnoredMethodIds)
                                ignored_method_ids
                              elsif !ignored_method_ids.nil?
                                DiverDown::Trace::IgnoredMethodIds.new(ignored_method_ids)
                              end

        @caller_paths = caller_paths&.to_set
        @filter_method_id_path = filter_method_id_path
      end

      # Trace the call stack of the block and build the definition
      #
      # @param title [String]
      # @param definition_group [String, nil]
      #
      # @return [DiverDown::Definition]
      def trace(title: SecureRandom.uuid, definition_group: nil, &)
        session = new_session(title:, definition_group:)
        session.start

        yield

        session.stop
        session.definition
      ensure
        # Ensure to stop the session
        session&.stop
      end

      # @param title [String]
      # @param definition_group [String, nil]
      #
      # @return [TracePoint]
      def new_session(title: SecureRandom.uuid, definition_group: nil)
        DiverDown::Trace::Session.new(
          module_set: @module_set,
          ignored_method_ids: @ignored_method_ids,
          caller_paths: @caller_paths,
          filter_method_id_path: @filter_method_id_path,
          definition: DiverDown::Definition.new(
            title:,
            definition_group:
          )
        )
      end
    end
  end
end
