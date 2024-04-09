# frozen_string_literal: true

module DiverDown
  class Definition
    class Source
      include Comparable

      # @param hash [Hash]
      def self.from_hash(hash)
        new(
          source_name: hash[:source_name] || hash['source_name'],
          dependencies: (hash[:dependencies] || hash['dependencies'] || []).map { DiverDown::Definition::Dependency.from_hash(_1) }
        )
      end

      # @param sources [Array<DiverDown::Definition::Source>]
      # @return [DiverDown::Definition::Source]
      def self.combine(*sources)
        raise ArgumentError, 'sources are empty' if sources.empty?

        unique_sources = sources.map(&:source_name).uniq
        raise ArgumentError, "sources are unmatched. (#{unique_sources})" unless unique_sources.length == 1

        all_dependencies = sources.flat_map(&:dependencies)

        new(
          source_name: unique_sources[0],
          dependencies: DiverDown::Definition::Dependency.combine(*all_dependencies)
        )
      end

      attr_reader :source_name

      # @param source_name [String] filename of the source file
      # @param dependencies [Array<DiverDown::Definition::Dependency>]
      def initialize(source_name:, dependencies: [])
        @source_name = source_name
        @dependency_map = dependencies.map { [_1.source_name, _1] }.to_h
      end

      # @param source [String]
      # @return [DiverDown::Definition::Dependency, nil] return nil if source is self.source
      def find_or_build_dependency(dependency_source_name)
        return if source_name == dependency_source_name

        @dependency_map[dependency_source_name] ||= DiverDown::Definition::Dependency.new(source_name: dependency_source_name)
      end

      # @param dependency_source_name [String]
      # @return [DiverDown::Definition::Dependency, nil]
      def dependency(dependency_source_name)
        @dependency_map[dependency_source_name]
      end

      # @return [Array<DiverDown::Definition::Dependency>]
      def dependencies
        @dependency_map.values.sort
      end

      # @return [Hash]
      def to_h
        {
          source_name:,
          dependencies: dependencies.map(&:to_h),
        }
      end

      # @param other [DiverDown::Definition::Source]
      # @return [Integer]
      def <=>(other)
        source_name <=> other.source_name
      end

      # @param other [Object, DiverDown::Definition::Source]
      # @return [Boolean]
      def ==(other)
        other.is_a?(self.class) &&
          source_name == other.source_name &&
          dependencies == other.dependencies
      end
      alias eq? ==
      alias eql? ==

      # @return [Integer]
      def hash
        [self.class, source_name, dependencies].hash
      end
    end
  end
end
