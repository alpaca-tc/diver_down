# frozen_string_literal: true

module DiverDown
  class Definition
    class MethodId
      VALID_CONTEXT = %w[instance class].freeze
      private_constant :VALID_CONTEXT

      include Comparable

      attr_reader :name, :context, :paths

      # @param hash [Hash]
      def self.from_hash(hash)
        new(
          name: hash[:name] || hash['name'],
          context: hash[:context] || hash['context'],
          paths: (hash[:paths] || hash['paths'] || [])
        )
      end

      # @param name [String, Symbol]
      # @param context ['instance', 'class']
      # @param paths [Set<String>]
      def initialize(name:, context:, paths: Set.new)
        raise ArgumentError, "invalid context: #{context}" unless VALID_CONTEXT.include?(context)

        @name = name.to_s
        @context = context.to_s
        @paths = paths.to_set
      end

      # @param path [Array<String>]
      def add_path(*paths)
        paths.each do
          @paths.add(_1)
        end
      end

      # @return [String]
      def human_method_name
        prefix = context == 'instance' ? '#' : '.'
        "#{prefix}#{name}"
      end

      # @return [Hash]
      def to_h
        {
          name:,
          context:,
          paths: @paths.sort,
        }
      end

      # @return [Integer]
      def hash
        [self.class, name, context, paths].hash
      end

      # @param other [DiverDown::Definition::MethodId]
      # @return [Integer]
      def <=>(other)
        [name, context] <=> [other.name, other.context]
      end

      # @param other [Object, DiverDown::Definition::Source]
      # @return [Boolean]
      def ==(other)
        other.is_a?(self.class) &&
          name == other.name &&
          context == other.context &&
          paths == other.paths
      end
      alias eq? ==
      alias eql? ==

      # @return [String]
      def inspect
        %(#<#{self.class} #{human_method_name} paths=#{paths.inspect}>")
      end
    end
  end
end
