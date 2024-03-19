# frozen_string_literal: true

require 'securerandom'

module Diverdown
  class Definition
    require 'diverdown/definition/source'
    require 'diverdown/definition/dependency'
    require 'diverdown/definition/modulee'
    require 'diverdown/definition/method_id'
    require 'diverdown/definition/bit_id'

    # @param hash [Hash]
    # @return [Diverdown::Definition]
    def self.from_hash(hash)
      new(
        title: hash[:title] || '',
        package: hash[:package],
        sources: (hash[:sources] || []).map do |source_hash|
          Diverdown::Definition::Source.from_hash(source_hash)
        end
      )
    end

    # @param title [String]
    # @param definitions [Array<Diverdown::Definition>]
    def self.combine(title:, definitions: [])
      all_sources = definitions.flat_map(&:sources)

      sources = all_sources.group_by(&:source_name).map do |_, same_sources|
        Diverdown::Definition::Source.combine(*same_sources)
      end

      new(
        title:,
        sources:
      )
    end

    attr_reader :title, :package, :parent, :children

    # @param title [String]
    # @param sources [Array<Diverdown::Definition::Source>]
    def initialize(title: '', package: nil, sources: [], parent: nil, children: [])
      @title = title
      @package = package
      @source_map = sources.map { [_1.source_name, _1] }.to_h
      @parent = parent
      @children = children.to_set
    end

    # @param source_name [String]
    # @return [Diverdown::Definition::Source]
    def find_or_build_source(source_name)
      @source_map[source_name] ||= Diverdown::Definition::Source.new(source_name:)
    end

    # @param source_name [String]
    # @return [Diverdown::Definition::Source, nil]
    def source(source_name)
      @source_map[source_name]
    end

    # @return [Array<Diverdown::Definition::Source>]
    def sources
      @source_map.values.sort
    end

    # @param parent [Diverdown::Definition]
    def parent=(parent)
      @parent = parent
      parent.children << self
    end

    # This definition is top level
    # @return [Boolean]
    def top?
      parent.nil?
    end

    # @return [Integer]
    def level
      return 0 if top?

      parent.level + 1
    end

    # @return [String]
    def to_h
      {
        title:,
        package:,
        sources: sources.map(&:to_h),
      }
    end

    # Combine two definitions into one
    # @param other_definition [Diverdown::Definition]
    # @return [self]
    def combine(other_definition)
      new_sources = (sources + other_definition.sources).group_by(&:source_name).map do |_, same_sources|
        last_source = same_sources.pop
        same_sources.inject(last_source) do |source, other_source|
          source.combine(other_source)
        end
      end

      @source_map = new_sources.map { [_1.source_name, _1] }.to_h

      self
    end

    # @param other [Object, Diverdown::Definition::Source]
    # @return [Boolean]
    def ==(other)
      other.is_a?(self.class) &&
        title == other.title &&
        package == other.package &&
        sources.sort == other.sources.sort &&
        parent == other.parent &&
        children == other.children
    end
    alias eq? ==
    alias eql? ==

    # @return [Integer]
    def hash
      [self.class, title, package, sources].hash
    end
  end
end
