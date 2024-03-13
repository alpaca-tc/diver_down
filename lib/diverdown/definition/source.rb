# frozen_string_literal: true

module Diverdown
  class Definition
    class Source
      include Comparable

      # @param hash [Hash]
      def self.from_hash(hash)
        new(
          source: hash[:source],
          dependencies: (hash[:dependencies] || []).map { Diverdown::Definition::Dependency.from_hash(_1) },
          modules: (hash[:modules] || []).map { Diverdown::Definition::Modulee.new(**_1) }
        )
      end

      attr_reader :source

      # @param source [String] filename of the source file
      # @param dependencies [Array<Diverdown::Definition::Dependency>]
      # @param modules [Array<Diverdown::Definition::Modulee>]
      def initialize(source:, dependencies: [], modules: [])
        @source = source
        @dependency_map = dependencies.map { [_1.source, _1] }.to_h
        @module_map = modules.map { [_1.name, _1] }.to_h
      end

      # @param source [String]
      # @return [Diverdown::Definition::Dependency, nil] return nil if source is self.source
      def dependency(source)
        return if self.source == source

        @dependency_map[source] ||= Diverdown::Definition::Dependency.new(source:)
      end

      # @param name [String]
      # @return [Diverdown::Definition::Modulee]
      def module(name)
        @module_map[name] ||= Diverdown::Definition::Modulee.new(name: name)
      end

      # @return [Array<Diverdown::Definition::Dependency>]
      def dependencies
        @dependency_map.values.sort
      end

      # @return [Array<Diverdown::Definition::Modulee>]
      def modules
        @module_map.values.sort
      end


      # @param other_source [Diverdown::Definition::Source]
      # @return [Diverdown::Definition::Source]
      def combine(other_source)
        raise ArgumentError, "source is unmatched. (#{source}, #{other_source.source})" unless source == other_source.source

        all_dependencies = dependencies + other_source.dependencies

        self.class.new(
          source:,
          dependencies: Diverdown::Definition::Dependency.combine(*all_dependencies),
          modules: (modules + other_source.modules).uniq
        )
      end

      # @return [Hash]
      def to_h
        {
          source:,
          dependencies: dependencies.map(&:to_h),
          modules: modules.map(&:to_h),
        }
      end

      # @param other [Diverdown::Definition::Source]
      # @return [Integer]
      def <=>(other)
        source <=> other.source
      end

      # @param other [Object, Diverdown::Definition::Source]
      # @return [Boolean]
      def ==(other)
        other.is_a?(self.class) &&
          source == other.source &&
          dependencies == other.dependencies &&
          modules.sort == other.modules.sort
      end
      alias eq? ==
      alias eql? ==

      # @return [Integer]
      def hash
        [self.class, source, dependencies, modules.sort].hash
      end
    end
  end
end
