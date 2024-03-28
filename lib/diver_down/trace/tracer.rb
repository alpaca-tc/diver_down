# frozen_string_literal: true

module DiverDown
  module Trace
    class Tracer
      StackContext = Data.define(:source, :method_id, :caller_location)

      # @return [Array<Symbol>]
      def self.trace_events
        @trace_events || %i[call c_call return c_return]
      end

      # @param events [Array<Symbol>]
      class << self
        attr_writer :trace_events
      end

      # @param module_set [DiverDown::Trace::ModuleSet, Array<Module, String>]
      # @param target_files [Array<String>, nil] if nil, trace all files
      # @param filter_method_id_path [#call, nil] filter method_id.path
      # @param module_set [DiverDown::Trace::ModuleSet, nil] for optimization
      # @param module_finder [#call] find module from source
      def initialize(module_set: [], target_files: nil, filter_method_id_path: nil, module_finder: nil)
        if target_files && !target_files.all? { Pathname.new(_1).absolute? }
          raise ArgumentError, "target_files must be absolute path(#{target_files})"
        end

        @module_set = if module_set.is_a?(DiverDown::Trace::ModuleSet)
                        module_set
                      else
                        DiverDown::Trace::ModuleSet.new(module_set)
                      end

        @target_file_set = target_files&.to_set
        @filter_method_id_path = filter_method_id_path
        @module_finder = module_finder
      end

      # Trace the call stack of the block and build the definition
      #
      # @param title [String]
      # @param definition_group [String, nil]
      #
      # @return [DiverDown::Definition]
      def trace(title:, definition_group: nil, &)
        call_stack = DiverDown::Trace::CallStack.new
        definition = DiverDown::Definition.new(
          definition_group:,
          title:
        )

        tracer = TracePoint.new(*self.class.trace_events) do |tp|
          case tp.event
          when :call, :c_call
            # puts "#{tp.method_id} #{tp.path}:#{tp.lineno}"
            mod = DiverDown::Helper.resolve_module(tp.self)
            source_name = DiverDown::Helper.normalize_module_name(mod) if !mod.nil? && @module_set.include?(mod)
            pushed = false

            unless source_name.nil?
              source = definition.find_or_build_source(source_name)

              # Determine module name from source
              module_names = @module_finder&.call(source)
              source.set_modules(module_names) if module_names

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
        end

        tracer.enable(&)

        definition
      end

      private

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
