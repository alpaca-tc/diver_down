# frozen_string_literal: true

module Diverdown
  class Definition
    # not typo. like "klass"
    class Modulee
      include Comparable

      attr_reader :name

      # @param name [String]
      def initialize(name:)
        @name = name
      end

      # @return [Hash]
      def to_h
        {
          name:,
        }
      end

      # @return [Integer]
      def <=>(other)
        name <=> other.name
      end

      # @param other [Object, Diverdown::Definition::Source]
      # @return [Boolean]
      def ==(other)
        other.is_a?(self.class) &&
          name == other.name
      end
      alias eq? ==
      alias eql? ==

      # @return [Integer]
      def hash
        [self.class, name].hash
      end
    end
  end
end
