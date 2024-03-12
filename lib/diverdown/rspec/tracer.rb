# frozen_string_literal: true

module Diverdown
  module RSpec
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

      # @param id [String]
      # @param title [String]
      # @param target_modules [Array<Module, String>]
      # @param target_files [Array<String>, nil] if nil, trace all files
      # @param filter_method_id_path [#call, nil] filter method_id.path
      def initialize(id:, title:, target_modules: [], target_files: nil, filter_method_id_path: nil)
        @id = id
        @title = title
        @module_set = Diverdown::RSpec::ModuleSet.new(target_modules)
        @target_file_set = target_files&.to_set
        @filter_method_id_path = filter_method_id_path
      end

      # Trace the call stack of the block and build the definition
      #
      # @return [Diverdown::Definition]
      def trace(&)
        call_stack = Diverdown::RSpec::CallStack.new
        definition = Diverdown::Definition.new(
          id: @id,
          title: @title
        )

        tracer = TracePoint.new(*self.class.trace_events) do |tp|
          tp.disable

          case tp.event
          when :call, :c_call
            # puts "#{tp.method_id} #{tp.path}:#{tp.lineno}"
            mod = Diverdown::Helper.resolve_module(tp.self)
            module_name = Diverdown::Helper.normalize_module_name(mod) if !mod.nil? && @module_set.include?(mod)

            if module_name.nil?
              call_stack.push
            else
              source = definition.source(module_name)

              unless call_stack.empty?
                # Add dependency to called source
                called_stack_context = call_stack.stack[-1]
                called_source = called_stack_context.source
                dependency = called_source.dependency(module_name)

                # `dependency.nil?` means module_name equals to called_source.source.
                # self-references are not tracked because it is not "dependency".
                if dependency
                  context = Diverdown::Helper.module?(tp.self) ? 'class' : 'instance'
                  method_id = dependency.method_id(name: tp.method_id, context:)
                  method_id_path = "#{called_stack_context.caller_location.path}:#{called_stack_context.caller_location.lineno}"
                  method_id_path = @filter_method_id_path.call(method_id_path) if @filter_method_id_path
                  method_id.add_path(method_id_path)
                end
              end

              # `caller_location` is nil if it is filtered by target_files
              caller_location = find_neast_caller_location

              if caller_location
                call_stack.push(
                  StackContext.new(
                    source:,
                    method_id: tp.method_id,
                    caller_location:
                  )
                )
              else
                call_stack.pop
              end
            end
          when :return, :c_return
            call_stack.pop
          end

          tp.enable
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
