# frozen_string_literal: true

module DiverDown
  module Trace
    class Session
      StackContext = Data.define(
        :source,
        :method_id,
        :path,
        :lineno
      )

      attr_reader :definition

      # @param [DiverDown::Trace::ModuleSet, nil] module_set
      # @param [DiverDown::Trace::IgnoredMethodIds, nil] ignored_method_ids
      # @param [Set<String>, nil] target_file_set
      # @param [#call, nil] filter_method_id_path
      def initialize(module_set: DiverDown::Trace::ModuleSet.new, ignored_method_ids: nil, target_file_set: nil, filter_method_id_path: nil, definition: DiverDown::Definition.new)
        @module_set = module_set
        @ignored_method_ids = ignored_method_ids
        @target_file_set = target_file_set
        @filter_method_id_path = filter_method_id_path
        @definition = definition
        @trace_point = build_trace_point
      end

      private

      def build_trace_point
        call_stack = DiverDown::Trace::CallStack.new

        TracePoint.new(*DiverDown::Trace::Tracer.trace_events) do |tp|
          # Skip the trace of the itself
          next if DiverDown::Trace::Session == tp.defined_class

          case tp.event
          when :call, :c_call
            # puts "#{tp.method_id} #{tp.path}:#{tp.lineno}"
            if call_stack.ignored?
              call_stack.push
              next
            end

            mod = DiverDown::Helper.resolve_module(tp.self)

            if !@ignored_method_ids.nil? && @ignored_method_ids.ignored?(mod, DiverDown::Helper.module?(tp.self), tp.method_id)
              # If this method is ignored, the call stack is ignored until the method returns.
              call_stack.push(ignored: true)
              next
            end

            source_name = DiverDown::Helper.normalize_module_name(mod) if !mod.nil? && @module_set.include?(mod)
            pushed = false

            unless source_name.nil?
              # If the call stack contains a call to a module to be traced
              # `@ignored_call_stack` is not nil means the call stack contains a call to a module to be ignored
              unless call_stack.empty?
                # Add dependency to called source
                called_stack_context = call_stack.stack[-1]
                called_source = called_stack_context.source
                dependency = called_source.find_or_build_dependency(source_name)

                # `dependency.nil?` means source_name equals to called_source.source.
                # self-references are not tracked because it is not "dependency".
                if dependency
                  context = DiverDown::Helper.module?(tp.self) ? 'class' : 'instance'
                  method_id = dependency.find_or_build_method_id(name: tp.method_id, context:)
                  method_id_path = "#{called_stack_context.path}:#{called_stack_context.lineno}"
                  method_id_path = @filter_method_id_path.call(method_id_path) if @filter_method_id_path
                  method_id.add_path(method_id_path)
                end
              end

              # `caller_location` is nil if it is filtered by target_files
              caller_location = find_neast_caller_location(call_stack.stack_size)

              if caller_location
                pushed = true
                source = @definition.find_or_build_source(source_name)

                call_stack.push(
                  StackContext.new(
                    source:,
                    method_id: tp.method_id,
                    path: caller_location.path,
                    lineno: caller_location.lineno
                  )
                )
              end
            end

            call_stack.push unless pushed
          when :return, :c_return
            call_stack.pop
          end
        rescue StandardError
          tp.disable
          raise
        end
      end

      def find_neast_caller_location(stack_size)
        excluded_frame_size = 1 # Ignore neast caller because it is stack of #find_neast_caller_location.
        finished_frame_size = excluded_frame_size + stack_size + 1
        frame_pos = 1

        # If @target_file_set is nil, return the caller location.
        return caller_locations(excluded_frame_size + 1, excluded_frame_size + 1)[0] if @target_file_set.nil?

        Thread.each_caller_location do
          break if finished_frame_size < frame_pos
          return _1 if @target_file_set.include?(_1.path)

          frame_pos += 1
        end

        nil
      end
    end
  end
end
