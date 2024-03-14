# frozen_string_literal: true

module Diverdown
  class Web
    class DefinitionToDot
      class SourceDecorator < BasicObject
        attr_reader :dependencies

        # @param source [Diverdown::Definition::Source]
        def initialize(source)
          @source = source
          @dependencies = source.dependencies.map { DependencyDecorator.new(_1) }
        end

        # @return [String]
        def label
          @source.source
        end

        # @return [String, nil]
        def tooltip
          nil
        end

        # @param action [Symbol]
        # @param args [Array]
        # @param options [Hash, nil]
        # @param block [Proc, nil]
        def method_missing(action, ...)
          if @source.respond_to?(action, true)
            @source.send(action, ...)
          else
            super
          end
        end

        # @param action [Symbol]
        # @param include_private [Boolean]
        # @return [Boolean]
        def respond_to_missing?(action, include_private = false)
          super || @source.respond_to?(action, include_private)
        end
      end

      class DependencyDecorator < BasicObject
        # @param dependency [Diverdown::Definition::dependency]
        def initialize(dependency)
          @dependency = dependency
        end

        # @return [String]
        def label
          @dependency.dependency
        end

        # @return [String, nil]
        def tooltip
          nil
        end

        # @param action [Symbol]
        # @param args [Array]
        # @param options [Hash, nil]
        # @param block [Proc, nil]
        def method_missing(action, ...)
          if @dependency.respond_to?(action, true)
            @dependency.send(action, ...)
          else
            super
          end
        end

        # @param action [Symbol]
        # @param include_private [Boolean]
        # @return [Boolean]
        def respond_to_missing?(action, include_private = false)
          super || @dependency.respond_to?(action, include_private)
        end
      end

      # @param definition [Diverdown::Definition]
      def initialize(definition)
        @definition = definition
        @io = Diverdown::IndentedStringIo.new
        @indent = 0
      end

      # @return [String]
      def to_s
        # <<~EOS
        #   digraph G {
        #     compound=true;
        #     subgraph cluster0 {
        #       b -> d;
        #     }
        #     subgraph cluster1 {
        #       e -> f;
        #     }
        #     b -> e [ltail=cluster0,lhead=cluster1];
        #   }
        # EOS
        sources = definition.sources
          .sort_by(&:source)
          .map { SourceDecorator.new(_1) }

        io.puts %(strict digraph "#{definition.title}" {)
        io.indented do
          sources.each do
            insert_source(_1)
          end
        end
        io.puts '}'
        io.string
      end

      private

      attr_reader :definition, :io

      def insert_source(source)
        if source.modules.empty?
          io.puts %("#{source.source}" #{build_attributes(label: source.label)})
        else
          insert_modules(source)
        end

        io.indented do
          source.dependencies.each do
            attributes = build_attributes(tooltip: _1.tooltip)
            io.write %("#{source.source}" -> "#{_1.source}")
            io.write %( #{attributes}) if attributes
            io.write "\n"
          end
        end
      end

      def insert_modules(source)
        buf = swap_io do
          *modules, last_module = *source.modules

          # last subgraph
          last_module_writer = proc do
            io.puts %( subgraph "cluster_#{last_module.name}" {), indent: false
            io.indented do
              source_attributes = build_attributes(label: last_module.name, _wrap: false)
              module_attributes = build_attributes(label: source.source)

              io.write %(#{source_attributes} "#{source.source}")
              io.write(" #{module_attributes}", indent: false) if module_attributes
              io.write "\n"
            end
            io.puts '}'
          end

          # wrapper subgraph
          modules_writer = modules.inject(last_module_writer) do |next_writer, mod|
            proc do
              io.puts %(subgraph "cluster_#{mod.name}" {)
              io.indented do
                attributes = build_attributes(label: mod.name, _wrap: false)
                io.write attributes
                next_writer.call
              end
              io.puts '}'
            end
          end

          modules_writer.call
        end

        io.write buf.string
      end

      # rubocop:disable Lint/UnderscorePrefixedVariableName
      # attrsの参考 https://qiita.com/rubytomato@github/items/51779135bc4b77c8c20d
      # attrs.merge!(label: 'a-b', headlabel: "head", taillabel: "tail")
      def build_attributes(_wrap: '[]', **attrs)
        attrs_str = attrs.filter_map { %(#{_1}="#{_2}") if _2 }.join(' ')

        return if attrs_str.empty?

        if _wrap
          "#{_wrap[0]}#{attrs_str}#{_wrap[1]}"
        else
          attrs_str
        end
      end
      # rubocop:enable Lint/UnderscorePrefixedVariableName

      def increase_indent
        @indent += 1
        yield
      ensure
        @indent -= 1
      end

      def swap_io
        old_io = @io
        @io = IndentedStringIo.new
        yield
        @io
      ensure
        @io = old_io
      end
    end
  end
end