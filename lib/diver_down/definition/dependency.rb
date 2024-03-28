# frozen_string_literal: true

module Diverdown
  class Definition
    class Dependency
      include Comparable

      # @param hash [Hash]
      # @return [Diverdown::Definition::Dependency]
      def self.from_hash(hash)
        method_ids = (hash[:method_ids] || []).map do
          Diverdown::Definition::MethodId.new(**_1)
        end

        new(
          source_name: hash[:source_name],
          method_ids:
        )
      end

      # @param dependencies [Array<Diverdown::Definition::Dependency>]
      # @return [Array<Diverdown::Definition::Dependency>]
      def self.combine(*dependencies)
        dependencies.group_by(&:source_name).map do |source_name, same_source_dependencies|
          new_dependency = new(source_name:)

          same_source_dependencies.each do |dependency|
            dependency.method_ids.each do |method_id|
              new_method_id = new_dependency.find_or_build_method_id(name: method_id.name, context: method_id.context)
              new_method_id.add_path(*method_id.paths)
            end
          end

          new_dependency
        end
      end

      attr_reader :source_name

      # @param source_name [String]
      # @param method_ids [Array<Diverdown::Definition::MethodId>]
      def initialize(source_name:, method_ids: [])
        @source_name = source_name
        @method_id_map = {
          'class' => {},
          'instance' => {},
        }

        method_ids.each do |method_id|
          @method_id_map[method_id.context][method_id.name] = method_id
        end
      end

      # @param name [String]
      # @param context ['instance', 'class']
      # @return [Diverdown::Definition::MethodId]
      def find_or_build_method_id(name:, context:)
        @method_id_map[context.to_s][name.to_s] ||= Diverdown::Definition::MethodId.new(name:, context:)
      end

      # @param name [String, Symbol]
      # @param context ['instance', 'class']
      # @return [Diverdown::Definition::MethodId, nil]
      def method_id(name:, context:)
        @method_id_map[context.to_s][name.to_s]
      end

      # @return [Array<Diverdown::Definition::MethodId>]
      def method_ids
        (@method_id_map['class'].values + @method_id_map['instance'].values).sort
      end

      # @return [Hash]
      def to_h
        {
          source_name:,
          method_ids: method_ids.map(&:to_h),
        }
      end

      # @return [Integer]
      def <=>(other)
        source_name <=> other.source_name
      end

      # @param other [Object, Diverdown::Definition::Source]
      # @return [Boolean]
      def ==(other)
        other.is_a?(self.class) &&
          source_name == other.source_name &&
          method_ids == other.method_ids
      end
      alias eq? ==
      alias eql? ==

      # @return [Integer]
      def hash
        [self.class, source_name, method_ids].hash
      end

      # @return [String]
      def inspect
        %(#<#{self.class} source_name="#{source_name}" method_ids=#{method_ids}>")
      end
    end
  end
end
