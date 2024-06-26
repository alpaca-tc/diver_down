# frozen_string_literal: true

module DiverDown
  module Trace
    # To handle call stacks obtained by TracePoint more efficiently.
    # TracePoint also acquires calls that are not trace targets, but for dependency extraction, we want to acquire only a list of targets.
    # In this class, push/pop is performed on all call/return, but it should always be possible to trace back to the caller of the target dependency at high speed.
    class CallStack
      class StackEmptyError < RuntimeError; end

      # @attr_reader stack [Integer] stack size
      attr_reader :stack_size

      def initialize
        @ignored_stack_size = nil
        @stack_size = 0
        @context_stack = {}
      end

      # @return [Boolean]
      def empty_context_stack?
        @context_stack.empty?
      end

      # @return [Array<Integer>]
      def context_stack_size
        @context_stack.keys
      end

      # @return [Array<Object>]
      def context_stack
        @context_stack.values
      end

      # @param context [Object, nil] User defined stack context.
      # @return [void]
      def push(context = nil, ignored: false)
        @stack_size += 1
        @context_stack[@stack_size] = context unless context.nil?
        @ignored_stack_size ||= @stack_size if ignored
      end

      # If a stack is not already a tracing target, some conditions are unnecessary so that it can be easily ignored.
      #
      # @return [Boolean]
      def ignored?
        !@ignored_stack_size.nil?
      end

      # @return [void]
      def pop
        raise StackEmptyError if @stack_size.zero?

        @context_stack.delete(@stack_size) if @context_stack.key?(@stack_size)
        @ignored_stack_size = nil if @ignored_stack_size && @ignored_stack_size == @stack_size
        @stack_size -= 1
      end
    end
  end
end
