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
        definition_group: hash[:definition_group],
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

    attr_reader :definition_group, :title

    # @param title [String]
    # @param sources [Array<Diverdown::Definition::Source>]
    def initialize(definition_group: nil, title: '', sources: [])
      @definition_group = definition_group
      @title = title
      @source_map = sources.map { [_1.source_name, _1] }.to_h
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

    # @return [String]
    def to_h
      {
        definition_group:,
        title:,
        sources: sources.map(&:to_h),
      }
    end

    # @return [String]
    def to_msgpack
      MessagePack.pack(to_h)
    end

    # @param other [Object, Diverdown::Definition::Source]
    # @return [Boolean]
    def ==(other)
      other.is_a?(self.class) &&
        definition_group == other.definition_group &&
        title == other.title &&
        sources.sort == other.sources.sort
    end
    alias eq? ==
    alias eql? ==

    # @return [Integer]
    def hash
      [self.class, definition_group, title, sources].hash
    end
  end
end
