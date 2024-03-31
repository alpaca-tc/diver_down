# frozen_string_literal: true

module DiverDown
  class Definition
    # not typo. like "klass"
    class Modulee
      include Comparable

      attr_reader :module_name

      # @param hash [Hash]
      def self.from_hash(hash)
        new(
          module_name: hash[:module_name] || hash['module_name']
        )
      end

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

      # @param other [Object, DiverDown::Definition::Source]
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
