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
        @stack_size = 0
        @stack = {}
      end

      # @return [Boolean]
      def empty?
        @stack.empty?
      end

      # @return [Array<Object>]
      def stack
        @stack.values
      end

      # @param context [Object, nil] User defined stack context.
      # @return [void]
      def push(context = nil)
        @stack_size += 1
        @stack[@stack_size] = context unless context.nil?
      end

      # @return [void]
      def pop
        raise StackEmptyError if @stack_size.zero?

        @stack.delete(@stack_size) if @stack.key?(@stack_size)
        @stack_size -= 1
      end
    end
  end
end
