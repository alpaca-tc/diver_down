# frozen_string_literal: true

module Diverdown
  class Definition
    # not typo. like "klass"
    class Modulee
      include Comparable

      attr_reader :module_name

      # @param name [String]
      def initialize(module_name:)
        @module_name = module_name
      end

      # @return [Hash]
      def to_h
        {
          module_name:,
        }
      end

      # @return [Integer]
      def <=>(other)
        module_name <=> other.module_name
      end

      # @param other [Object, Diverdown::Definition::Source]
      # @return [Boolean]
      def ==(other)
        other.is_a?(self.class) &&
          module_name == other.module_name
      end
      alias eq? ==
      alias eql? ==

      # @return [Integer]
      def hash
        [self.class, module_name].hash
      end
    end
  end
end
