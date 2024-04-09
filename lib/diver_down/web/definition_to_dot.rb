# frozen_string_literal: true

require 'json'
require 'cgi'

module DiverDown
  class Web
    class DefinitionToDot
      ATTRIBUTE_DELIMITER = ' '

      class MetadataStore
        attr_reader :to_a

        def initialize
          @prefix = 'graph_'
          @to_a = []
        end

        # @param type [Symbol]
        # @param record [DiverDown::Definition::Source, DiverDown::Definition::Dependency, DiverDown::Definition::Modulee]
        def issue_id(record)
          metadata = case record
                     when DiverDown::Definition::Source
                       source_to_metadata(record)
                     when DiverDown::Definition::Dependency
                       dependency_to_metadata(record)
                     when DiverDown::Definition::Modulee
                       module_to_metadata(record)
                     else
                       raise NotImplementedError, "not implemented yet #{record.class}"
                     end

          id = "#{@prefix}#{@to_a.length + 1}"
          @to_a.push(metadata.merge(id:))
          id
        end

        private

        def length
          @to_a.length
        end

        def source_to_metadata(record)
          {
            type: 'source',
            source_name: record.source_name,
          }
        end

        def dependency_to_metadata(record)
          {
            type: 'dependency',
            source_name: record.source_name,
            method_ids: record.method_ids.sort.map do
              {
                name: _1.name,
                context: _1.context,
              }
            end,
          }
        end

        def module_to_metadata(record)
          {
            type: 'module',
            module_name: record.module_name,
          }
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
        @metadata_store = MetadataStore.new
      end

      # @return [Array<Hash>]
      def metadata
        @metadata_store.to_a
      end

      # @return [String]
      def to_s
        sources = definition.sources.sort_by(&:source_name)

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
          io.puts %("#{source.source_name}" #{build_attributes(label: source.source_name, id: @metadata_store.issue_id(source))})
        else
          insert_modules(source)
        end

        source.dependencies.each do
          attributes = {
            id: @metadata_store.issue_id(_1),
          }
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
              module_attributes = build_attributes(label: last_module.module_name, id: @metadata_store.issue_id(last_module), _wrap: false)
              source_attributes = build_attributes(label: source.source_name, id: @metadata_store.issue_id(source))

              io.puts %(#{module_attributes} "#{source.source_name}" #{source_attributes})
            end
            io.puts '}'
          end

          # wrapper subgraph
          modules_writer = modules.inject(last_module_writer) do |next_writer, mod|
            proc do
              io.puts %(subgraph "#{module_label(mod)}" {)
              io.indented do
                attributes = build_attributes(label: mod.module_name, id: @metadata_store.issue_id(mod), _wrap: false)
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
    end
  end
end
