# frozen_string_literal: true

require 'json'
require 'cgi'

module DiverDown
  class Web
    class DefinitionToDot
      ATTRIBUTE_DELIMITER = ' '
      MODULE_DELIMITER = '::'

      # Between modules is prominently distanced
      MODULE_MINLEN = 3

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
            modules = module_store.get_modules(data.source_name).map do
              {
                module_name: _1,
              }
            end

            {
              id:,
              type: 'source',
              source_name: data.source_name,
              memo: module_store.get_memo(data.source_name),
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
      def initialize(definition, module_store, compound: false, concentrate: false, only_module: false)
        @definition = definition
        @module_store = module_store
        @io = DiverDown::Web::IndentedStringIo.new
        @indent = 0
        @compound = compound || only_module # When only-module is enabled, dependencies between modules are displayed as compound.
        @compound_map = Hash.new { |h, k| h[k] = {} } # Hash{ ltail => Hash{ lhead => issued id } }
        @concentrate = concentrate
        @only_module = only_module
        @metadata_store = MetadataStore.new(module_store)
      end

      # @return [Array<Hash>]
      def metadata
        @metadata_store.to_a
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

      attr_reader :definition, :module_store, :io

      def render_only_modules
        # Hash{ from_module => { to_module => Array<DiverDown::Definition::Dependency> } }
        dependency_map = Hash.new { |h, k| h[k] = Hash.new { |hi, ki| hi[ki] = [] } }

        definition.sources.sort_by(&:source_name).each do |source|
          source_modules = module_store.get_modules(source.source_name)
          next if source_modules.empty?

          source.dependencies.each do |dependency|
            dependency_modules = module_store.get_modules(dependency.source_name)
            next if dependency_modules.empty?

            dependency_map[source_modules][dependency_modules].push(dependency)
          end
        end

        # Remove duplicated prefix modules
        # from [["A"], ["A", "B"]] to [["A", "B"]]
        uniq_modules = [*dependency_map.keys, *dependency_map.values.map(&:keys).flatten(1)].uniq
        uniq_modules.reject! do |modules|
          modules.empty? ||
            uniq_modules.any? { _1[0..modules.size - 1] == modules && _1.length > modules.size }
        end

        uniq_modules.each do |specific_module_names|
          buf = swap_io do
            indexes = (0..(specific_module_names.length - 1)).to_a

            chain_yield(indexes) do |index, next_proc|
              module_names = specific_module_names[0..index]
              module_name = specific_module_names[index]

              io.puts %(subgraph "#{escape_quote(module_label(module_names))}" {)
              io.indented do
                io.puts %(id="#{@metadata_store.issue_modules_id(module_names)}")
                io.puts %(label="#{escape_quote(module_name)}")
                io.puts %("#{escape_quote(module_name)}" #{build_attributes(label: module_name, id: @metadata_store.issue_modules_id(module_names))})

                next_proc&.call
              end
              io.puts '}'
            end
          end

          io.write buf.string
        end

        dependency_map.each do |from_modules, h|
          h.each do |to_modules, all_dependencies|
            # Do not render standalone source
            # Do not render self-dependency
            next if from_modules.empty? || to_modules.empty? || from_modules == to_modules

            dependencies = DiverDown::Definition::Dependency.combine(*all_dependencies)

            dependencies.each do
              attributes = {}
              ltail = module_label(*from_modules)
              lhead = module_label(*to_modules)

              # Already rendered dependencies between modules
              # Add the dependency to the edge of the compound
              if @compound_map[ltail].include?(lhead)
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
                minlen: MODULE_MINLEN
              )

              io.write(%("#{escape_quote(from_modules[-1])}" -> "#{escape_quote(to_modules[-1])}"))
              io.write(%( #{build_attributes(**attributes)}), indent: false) unless attributes.empty?
              io.write("\n")
            end
          end
        end
      end

      def render_sources
        by_modules = definition.sources.group_by do |source|
          module_store.get_modules(source.source_name)
        end

        # Remove duplicated prefix modules
        # from [["A"], ["A", "B"]] to [["A", "B"]]
        uniq_modules = by_modules.keys.uniq
        uniq_modules = uniq_modules.reject do |modules|
          uniq_modules.any? { _1[0..modules.size - 1] == modules && _1.length > modules.size }
        end

        uniq_modules.each do |full_modules|
          # Render module and source
          if full_modules.empty?
            sources = by_modules[full_modules].sort_by(&:source_name)

            sources.each do |source|
              insert_source(source)
            end
          else
            buf = swap_io do
              indexes = (0..(full_modules.length - 1)).to_a

              chain_yield(indexes) do |index, next_proc|
                module_names = full_modules[0..index]
                module_name = module_names[-1]

                io.puts %(subgraph "#{escape_quote(module_label(module_names))}" {)
                io.indented do
                  io.puts %(id="#{@metadata_store.issue_modules_id(module_names)}")
                  io.puts %(label="#{escape_quote(module_name)}")

                  sources = (by_modules[module_names] || []).sort_by(&:source_name)
                  sources.each do |source|
                    insert_source(source)
                  end

                  next_proc&.call
                end
                io.puts '}'
              end
            end

            io.write buf.string
          end
        end

        definition.sources.sort_by(&:source_name).each do |source|
          insert_dependencies(source)
        end
      end

      def insert_source(source)
        io.puts %("#{escape_quote(source.source_name)}" #{build_attributes(label: source.source_name, id: @metadata_store.issue_source_id(source))})
      end

      def insert_dependencies(source)
        source.dependencies.each do
          attributes = {}
          ltail = module_label(*module_store.get_modules(source.source_name))
          lhead = module_label(*module_store.get_modules(_1.source_name))

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
              minlen: MODULE_MINLEN
            )
          else
            attributes.merge!(
              id: @metadata_store.issue_dependency_id(_1)
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

      def module_label(*modules)
        return if modules.empty?

        "cluster_#{modules.join(MODULE_DELIMITER)}"
      end

      def escape_quote(string)
        string.to_s.gsub(/"/, '\"')
      end
    end
  end
end
