# frozen_string_literal: true

module DiverDown
  class Web
    class DefinitionToDot
      ATTRIBUTE_DELIMITER = ' '

      class SourceDecorator < BasicObject
        attr_reader :dependencies

        # @param source [DiverDown::Definition::Source]
        def initialize(source)
          @source = source
          @dependencies = source.dependencies.map { DependencyDecorator.new(_1) }
        end

        # @return [String]
        def label
          @source.source_name
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
        # @param dependency [DiverDown::Definition::dependency]
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

      # @param definition [DiverDown::Definition]
      # @param compound [Boolean]
      # @param concentrate [Boolean] https://graphviz.org/docs/attrs/concentrate/
      def initialize(definition, compound: false, concentrate: false)
        @definition = definition
        @io = DiverDown::IndentedStringIo.new
        @indent = 0
        @compound = compound
        @compound_map = Hash.new { |h, k| h[k] = Set.new } # { ltail => Set<lhead> }
        @concentrate = concentrate
      end

      # @return [String]
      def to_s
        sources = definition.sources
          .sort_by(&:source_name)
          .map { SourceDecorator.new(_1) }

        io.puts %(strict digraph "#{definition.title}" {)
        io.indented do
          io.puts('compound=true') if @compound
          io.puts('concentrate=true') if @concentrate
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
          io.puts %("#{source.source_name}" #{build_attributes(label: source.label)})
        else
          insert_modules(source)
        end

        source.dependencies.each do
          attributes = {}
          ltail = module_label(*source.modules)
          lhead = module_label(*definition.source(_1.source_name).modules)
          skip_rendering = false

          if @compound && (ltail || lhead)
            # Rendering of dependencies between modules is done only once
            between_modules = ltail != lhead
            skip_rendering ||= @compound_map[ltail].include?(lhead) if between_modules
            @compound_map[ltail].add(lhead)

            attributes.merge!(
              ltail:,
              lhead:,
              minlen: (between_modules ? 3 : nil) # Between modules is prominently distanced
            )
          end

          next if skip_rendering

          io.write(%("#{source.source_name}" -> "#{_1.source_name}"))
          io.write(%( #{build_attributes(**attributes)}), indent: false) unless attributes.empty?
          io.write("\n")
        end
      end

      def insert_modules(source)
        buf = swap_io do
          *modules, last_module = *source.modules

          # last subgraph
          last_module_writer = proc do
            io.puts %(#{' ' unless modules.empty?}subgraph "#{module_label(last_module)}" {), indent: false
            io.indented do
              module_attributes = build_attributes(label: last_module.module_name, _wrap: false)
              source_attributes = build_attributes(label: source.source_name, id: build_id(:source, source.source_name))

              io.puts %(#{module_attributes} "#{source.source_name}" #{source_attributes})
            end
            io.puts '}'
          end

          # wrapper subgraph
          modules_writer = modules.inject(last_module_writer) do |next_writer, mod|
            proc do
              io.puts %(subgraph "#{module_label(mod)}" {)
              io.indented do
                attributes = build_attributes(label: mod.module_name, _wrap: false)
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
      def build_attributes(_wrap: '[]', **attrs)
        attrs = attrs.reject { _2.nil? || _2 == '' }
        return if attrs.empty?

        attrs_str = attrs.map { %(#{_1}="#{_2}") }.join(ATTRIBUTE_DELIMITER)

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

      def module_label(*modules)
        return if modules.empty?

        "cluster_#{modules[0].module_name}"
      end

      def build_id(type, identity)
        "#{type}-#{identity}"
      end
    end
  end
end
