# frozen_string_literal: true

require 'json'
require 'cgi'

module DiverDown
  class Web
    class DefinitionToDot
      ATTRIBUTE_DELIMITER = ' '

      # Between modules is prominently distanced
      MODULE_MINLEN = 3

      class DotMetadataStore
        DotMetadata = Data.define(:id, :type, :data, :metadata) do
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
            {
              id:,
              type: 'source',
              source_name: data.source_name,
              memo: metadata.source(data.source_name).memo,
              module: metadata.source(data.source_name).module,
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
              module: data,
            }
          end
        end

        def initialize(metadata)
          @prefix = 'graph_'
          @metadata = metadata

          # Hash{ id => DotMetadata }
          @to_h = {}
        end

        # @param type [Symbol]
        # @param record [DiverDown::Definition::Source]
        # @return [String]
        def issue_source_id(source)
          build_dot_metadata_and_return_id(:source, source)
        end

        # @param dependency [DiverDown::Definition::Dependency]
        # @return [String]
        def issue_dependency_id(dependency)
          build_dot_metadata_and_return_id(:dependency, [dependency])
        end

        # @param module_names [Array<String>]
        # @return [String]
        def issue_module_id(modulee)
          issued_metadata = @to_h.values.find { _1.type == :module && _1.data == modulee }

          if issued_metadata
            issued_metadata.id
          else
            build_dot_metadata_and_return_id(:module, modulee)
          end
        end

        # @param id [String]
        # @param dependency [DiverDown::Definition::Dependency]
        def append_dependency(id, dependency)
          dot_metadata = @to_h.fetch(id)
          dependencies = dot_metadata.data
          combined_dependencies = DiverDown::Definition::Dependency.combine(*dependencies, dependency)
          dot_metadata.data.replace(combined_dependencies)
        end

        # @return [Array<Hash>]
        def to_a
          @to_h.values.map(&:to_h)
        end

        private

        def build_dot_metadata_and_return_id(type, data)
          id = "#{@prefix}#{length + 1}"
          dot_metadata = DotMetadata.new(id:, type:, data:, metadata: @metadata)
          @to_h[id] = dot_metadata

          id
        end

        def length
          @to_h.length
        end
      end

      # @param definition [DiverDown::Definition]
      # @param metadata [DiverDown::Web::Metadata]
      # @param compound [Boolean]
      # @param concentrate [Boolean] https://graphviz.org/docs/attrs/concentrate/
      def initialize(definition, metadata, compound: false, concentrate: false, only_module: false)
        @definition = definition
        @metadata = metadata
        @io = DiverDown::Web::IndentedStringIo.new
        @indent = 0
        @compound = compound || only_module # When only-module is enabled, dependencies between modules are displayed as compound.
        @compound_map = Hash.new { |h, k| h[k] = {} } # Hash{ ltail => Hash{ lhead => issued id } }
        @concentrate = concentrate
        @only_module = only_module
        @dot_metadata_store = DotMetadataStore.new(metadata)
      end

      # @return [Array<Hash>]
      def dot_metadata
        @dot_metadata_store.to_a
      end

      # @return [String]
      def to_s
        io.puts %(strict digraph "#{escape_quote(definition.title)}" {)
        io.indented do
          io.puts('compound=true') if @compound
          io.puts('concentrate=true') if @concentrate

          if @only_module
            render_only_modules
          else
            render_sources
          end
        end
        io.puts '}'
        io.string
      end

      private

      attr_reader :definition, :metadata, :io

      def render_only_modules
        # Hash{ from_module => { to_module => Array<DiverDown::Definition::Dependency> } }
        dependency_map = Hash.new { |h, k| h[k] = Hash.new { |hi, ki| hi[ki] = [] } }

        definition.sources.sort_by(&:source_name).each do |source|
          source_module = metadata.source(source.source_name).module
          next if source_module.empty?

          source.dependencies.each do |dependency|
            dependency_module = metadata.source(dependency.source_name).module
            next if dependency_module.empty?

            dependency_map[source_module][dependency_module].push(dependency)
          end
        end

        # Remove duplicated prefix modules
        uniq_modules = [*dependency_map.keys, *dependency_map.values.map(&:keys).flatten].uniq.sort
        uniq_modules.reject!(&:nil?)

        uniq_modules.each do |modulee|
          io.puts %(subgraph "#{escape_quote(module_label(modulee))}" {)
          io.indented do
            io.puts %(id="#{@dot_metadata_store.issue_module_id(modulee)}")
            io.puts %(label="#{escape_quote(modulee)}")
            io.puts %("#{escape_quote(modulee)}" #{build_attributes(label: modulee, id: @dot_metadata_store.issue_module_id(modulee))})
          end
          io.puts '}'
        end

        dependency_map.keys.sort_by(&:to_s).each do |from_module|
          dependency_map.fetch(from_module).keys.sort_by(&:to_s).each do |to_module|
            all_dependencies = dependency_map.fetch(from_module).fetch(to_module)

            # Do not render standalone source
            # Do not render self-dependency
            next if from_module.nil? || to_module.empty? || from_module == to_module

            dependencies = DiverDown::Definition::Dependency.combine(*all_dependencies)

            dependencies.each do
              attributes = {}
              ltail = module_label(from_module)
              lhead = module_label(to_module)

              # Already rendered dependencies between modules
              # Add the dependency to the edge of the compound
              if @compound_map[ltail].include?(lhead)
                compound_id = @compound_map[ltail][lhead]
                @dot_metadata_store.append_dependency(compound_id, _1)
                next
              end

              compound_id = @dot_metadata_store.issue_dependency_id(_1)
              @compound_map[ltail][lhead] = compound_id

              attributes.merge!(
                id: compound_id,
                ltail:,
                lhead:,
                minlen: MODULE_MINLEN
              )

              io.write(%("#{escape_quote(from_module)}" -> "#{escape_quote(to_module)}"))
              io.write(%( #{build_attributes(**attributes)}), indent: false) unless attributes.empty?
              io.write("\n")
            end
          end
        end
      end

      def render_sources
        # Hash{ module => sources }
        # Hash{ String => Array<DiverDown::Definition::Source> }
        by_module = definition.sources.group_by do |source|
          metadata.source(source.source_name).module
        end

        # Render subgraph for each module and its sources second
        by_module.keys.sort_by(&:to_s).each do |modulee|
          sources = by_module.fetch(modulee).sort_by(&:source_name)

          if modulee.nil?
            sources.each do |source|
              io.puts build_source_node(source)
            end
          else
            io.puts %(subgraph "#{escape_quote(module_label(modulee))}" {)
            io.indented do
              io.puts %(id="#{@dot_metadata_store.issue_module_id(modulee)}")
              io.puts %(label="#{escape_quote(modulee)}")

              sources.each do |source|
                io.puts build_source_node(source)
              end
            end
            io.puts '}'
          end
        end

        # Render dependencies last
        definition.sources.sort_by(&:source_name).each do |source|
          insert_dependencies(source)
        end
      end

      def build_source_node(source)
        %("#{escape_quote(source.source_name)}" #{build_attributes(label: source.source_name, id: @dot_metadata_store.issue_source_id(source))})
      end

      def insert_dependencies(source)
        source.dependencies.each do
          attributes = {}
          ltail = module_label(metadata.source(source.source_name).module)
          lhead = module_label(metadata.source(_1.source_name).module)

          if @compound && (ltail || lhead)
            # Rendering of dependencies between modules is done only once
            between_modules = ltail != lhead

            # Already rendered dependencies between modules
            # Add the dependency to the edge of the compound
            if between_modules && @compound_map[ltail].include?(lhead)
              compound_id = @compound_map[ltail][lhead]
              @dot_metadata_store.append_dependency(compound_id, _1)
              next
            end

            compound_id = @dot_metadata_store.issue_dependency_id(_1)
            @compound_map[ltail][lhead] = compound_id

            attributes.merge!(
              id: compound_id,
              ltail:,
              lhead:,
              minlen: MODULE_MINLEN
            )
          else
            attributes.merge!(
              id: @dot_metadata_store.issue_dependency_id(_1)
            )
          end

          io.write(%("#{escape_quote(source.source_name)}" -> "#{escape_quote(_1.source_name)}"))
          io.write(%( #{build_attributes(**attributes)}), indent: false) unless attributes.empty?
          io.write("\n")
        end
      end

      def chain_yield(values, &block)
        *head, tail = values

        last_proc = proc do
          block.call(tail, nil)
        end

        chain_proc = head.inject(last_proc) do |next_proc, value|
          proc do
            block.call(value, next_proc)
          end
        end

        chain_proc.call
      end

      # rubocop:disable Lint/UnderscorePrefixedVariableName
      # attrsの参考 https://qiita.com/rubytomato@github/items/51779135bc4b77c8c20d
      def build_attributes(_wrap: '[]', **attrs)
        attrs = attrs.reject { _2.nil? || _2 == '' }
        return if attrs.empty?

        attrs_str = attrs.map { %(#{_1}="#{escape_quote(_2)}") }.join(ATTRIBUTE_DELIMITER)

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

      def module_label(modulee)
        return if modulee.nil?

        "cluster_#{modulee}"
      end

      def escape_quote(string)
        string.to_s.gsub(/"/, '\"')
      end
    end
  end
end
