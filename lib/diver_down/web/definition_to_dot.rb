# frozen_string_literal: true

require 'json'
require 'cgi'

module DiverDown
  class Web
    class DefinitionToDot
      ATTRIBUTE_DELIMITER = ' '

      class MetadataStore
        Metadata = Data.define(:id, :type, :data, :module_store) do
          # @return [Hash]
          def to_h
            case type
            when :source
              source_to_h
            when :dependency
              dependency_to_h
            when :module
              module_to_h
            else
              raise NotImplementedError, "not implemented yet #{type}"
            end
          end

          private

          def source_to_h
            modules = module_store.get(data.source_name).map do
              {
                module_name: _1,
              }
            end

            {
              id:,
              type: 'source',
              source_name: data.source_name,
              modules:,
            }
          end

          def dependency_to_h
            {
              id:,
              type: 'dependency',
              dependencies: data.map do |dependency|
                {
                  source_name: dependency.source_name,
                  method_ids: dependency.method_ids.sort.map do
                    {
                      name: _1.name,
                      context: _1.context,
                    }
                  end,
                }
              end,
            }
          end

          def module_to_h
            {
              id:,
              type: 'module',
              modules: data.map do
                {
                  module_name: _1,
                }
              end,
            }
          end
        end

        def initialize(module_store)
          @prefix = 'graph_'
          @module_store = module_store

          # Hash{ id => Metadata }
          @to_h = {}
        end

        # @param type [Symbol]
        # @param record [DiverDown::Definition::Source]
        # @return [String]
        def issue_source_id(source)
          build_metadata_and_return_id(:source, source)
        end

        # @param dependency [DiverDown::Definition::Dependency]
        # @return [String]
        def issue_dependency_id(dependency)
          build_metadata_and_return_id(:dependency, [dependency])
        end

        # @param module_names [Array<String>]
        # @return [String]
        def issue_modules_id(module_names)
          issued_metadata = @to_h.values.find { _1.type == :module && _1.data == module_names }

          if issued_metadata
            issued_metadata.id
          else
            build_metadata_and_return_id(:module, module_names)
          end
        end

        # @param id [String]
        # @param dependency [DiverDown::Definition::Dependency]
        def append_dependency(id, dependency)
          metadata = @to_h.fetch(id)
          dependencies = metadata.data
          combined_dependencies = DiverDown::Definition::Dependency.combine(*dependencies, dependency)
          metadata.data.replace(combined_dependencies)
        end

        # @return [Array<Hash>]
        def to_a
          @to_h.values.map(&:to_h)
        end

        private

        def build_metadata_and_return_id(type, data)
          id = "#{@prefix}#{length + 1}"
          metadata = Metadata.new(id:, type:, data:, module_store: @module_store)
          @to_h[id] = metadata

          id
        end

        def length
          @to_h.length
        end
      end

      # @param definition [DiverDown::Definition]
      # @param module_store [DiverDown::ModuleStore]
      # @param compound [Boolean]
      # @param concentrate [Boolean] https://graphviz.org/docs/attrs/concentrate/
      def initialize(definition, module_store, compound: false, concentrate: false)
        @definition = definition
        @module_store = module_store
        @io = DiverDown::IndentedStringIo.new
        @indent = 0
        @compound = compound
        @compound_map = Hash.new { |h, k| h[k] = {} } # Hash{ ltail => Hash{ lhead => issued id } }
        @concentrate = concentrate
        @metadata_store = MetadataStore.new(module_store)
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

      attr_reader :definition, :module_store, :io

      def insert_source(source)
        if module_store.get(source.source_name).empty?
          io.puts %("#{source.source_name}" #{build_attributes(label: source.source_name, id: @metadata_store.issue_source_id(source))})
        else
          insert_modules(source)
        end

        source.dependencies.each do
          attributes = {}
          ltail = module_label(*module_store.get(source.source_name))
          lhead = module_label(*module_store.get(_1.source_name))

          if @compound && (ltail || lhead)
            # Rendering of dependencies between modules is done only once
            between_modules = ltail != lhead

            # Already rendered dependencies between modules
            # Add the dependency to the edge of the compound
            if between_modules && @compound_map[ltail].include?(lhead)
              compound_id = @compound_map[ltail][lhead]
              @metadata_store.append_dependency(compound_id, _1)
              next
            end

            compound_id = @metadata_store.issue_dependency_id(_1)
            @compound_map[ltail][lhead] = compound_id

            attributes.merge!(
              id: compound_id,
              ltail:,
              lhead:,
              minlen: (between_modules ? 3 : nil) # Between modules is prominently distanced
            )
          else
            attributes.merge!(
              id: @metadata_store.issue_dependency_id(_1)
            )
          end

          io.write(%("#{source.source_name}" -> "#{_1.source_name}"))
          io.write(%( #{build_attributes(**attributes)}), indent: false) unless attributes.empty?
          io.write("\n")
        end
      end

      def insert_modules(source)
        buf = swap_io do
          all_module_names = module_store.get(source.source_name)
          *head_module_indexes, _tail_module_index = (0..(all_module_names.length - 1)).to_a

          # last subgraph
          last_module_writer = proc do
            module_names = all_module_names
            module_name = module_names[-1]

            io.puts %(subgraph "#{module_label(module_name)}" {)
            io.indented do
              io.puts %(id="#{@metadata_store.issue_modules_id(module_names)}")
              io.puts %(label="#{module_name}")
              io.puts %("#{source.source_name}" #{build_attributes(label: source.source_name, id: @metadata_store.issue_source_id(source))})
            end
            io.puts '}'
          end

          # wrapper subgraph
          modules_writer = head_module_indexes.inject(last_module_writer) do |next_writer, module_index|
            proc do
              module_names = all_module_names[0..module_index]
              module_name = module_names[-1]

              io.puts %(subgraph "#{module_label(module_name)}" {)
              io.indented do
                io.puts %(id="#{@metadata_store.issue_modules_id(module_names)}")
                io.puts %(label="#{module_name}")
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

        "cluster_#{modules[0]}"
      end
    end
  end
end
