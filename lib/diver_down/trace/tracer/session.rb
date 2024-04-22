# frozen_string_literal: true

module DiverDown
  module Trace
    class Tracer
      class Session
        class NotStarted < StandardError; end

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

        # @return [void]
        def start
          @trace_point.enable
        end

        # @return [void]
        def stop
          @trace_point.disable
        end

        private

        def build_trace_point
          call_stack = DiverDown::Trace::CallStack.new

          TracePoint.new(*DiverDown::Trace::Tracer.trace_events) do |tp|
            # Skip the trace of the library itself
            next if tp.path&.start_with?(DiverDown::LIB_DIR)
            next if TracePoint == tp.defined_class

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
                source = @definition.find_or_build_source(source_name)

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
                    method_id_path = "#{called_stack_context.caller_location.path}:#{called_stack_context.caller_location.lineno}"
                    method_id_path = @filter_method_id_path.call(method_id_path) if @filter_method_id_path
                    method_id.add_path(method_id_path)
                  end
                end

                # `caller_location` is nil if it is filtered by target_files
                caller_location = find_neast_caller_location

                if caller_location
                  pushed = true

                  call_stack.push(
                    StackContext.new(
                      source:,
                      method_id: tp.method_id,
                      caller_location:
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

        def find_neast_caller_location
          return caller_locations(2, 2)[0] if @target_file_set.nil?

          Thread.each_caller_location do
            return _1 if @target_file_set.include?(_1.path)
          end

          nil
        end
      end
    end
  end
end
