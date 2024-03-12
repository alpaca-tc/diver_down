# frozen_string_literal: true

RSpec.describe Diverdown::RSpec::Tracer do
  describe '#trace' do
    describe 'when tracing script' do
      # @param path [String]
      # @return [Diverdown::Definition]
      def trace_fixture(path, module_set: [], target_files: nil, filter_method_id_path: nil)
        # NOTE: Script need to define .run method
        script = fixture_path(path)
        load script, AntipollutionModule
        antipollution_environment = AntipollutionKlass.allocate

        tracer = described_class.new(
          id: 'id',
          title: 'title',
          module_set:,
          target_files:,
          filter_method_id_path:
        )

        tracer.trace do
          antipollution_environment.send(:run)
        end
      end

      # fill default values
      def fill_default(hash)
        hash[:id] ||= ''
        hash[:title] ||= ''
        hash[:sources] ||= []
        hash[:sources].each do |source|
          source[:dependencies] ||= []
          source[:modules] ||= []

          source[:dependencies].each do |dependency|
            dependency[:method_ids] ||= []
          end
        end
        hash
      end

      before do
        stub_const('AntipollutionModule', Module.new)
        stub_const('AntipollutionKlass', Class.new)

        AntipollutionKlass.include(AntipollutionModule)
      end

      it 'traces tracer_module.rb' do
        definition = trace_fixture(
          'tracer_module.rb',
          module_set: [
            'AntipollutionModule::A',
            'AntipollutionModule::B',
            'AntipollutionModule::C',
          ]
        )

        expect(definition.to_h).to match(fill_default(
          id: 'id',
          title: 'title',
          sources: [
            {
              source: 'AntipollutionModule::A',
              dependencies: [
                {
                  source: 'AntipollutionModule::B',
                  method_ids: [
                    {
                      context: 'class',
                      name: 'call_c',
                      paths: [
                        match('tracer_module.rb:8'),
                      ],
                    },
                  ],
                },
              ],
            }, {
              source: 'AntipollutionModule::B',
              dependencies: [
                {
                  source: 'AntipollutionModule::C',
                  method_ids: [
                    {
                      context: 'class',
                      name: 'call_d',
                      paths: [
                        match('tracer_module.rb:14'),
                      ],
                    },
                  ],
                },
              ],
            }, {
              source: 'AntipollutionModule::C',
            },
          ]
        ))
      end

      it 'traces tracer_module.rb with target_files' do
        definition = trace_fixture(
          'tracer_module.rb',
          module_set: [
            'AntipollutionModule::A',
            'AntipollutionModule::B',
            'AntipollutionModule::C',
          ],
          target_files: []
        )

        expect(definition.to_h).to match(fill_default(
          id: 'id',
          title: 'title',
          sources: [
            {
              source: 'AntipollutionModule::A',
              dependencies: [],
            }, {
              source: 'AntipollutionModule::B',
              dependencies: [],
            }, {
              source: 'AntipollutionModule::C',
            },
          ]
        ))
      end

      it 'traces tracer_class.rb' do
        definition = trace_fixture(
          'tracer_class.rb',
          module_set: [
            'AntipollutionModule::A',
            'AntipollutionModule::B',
            'AntipollutionModule::C',
            'AntipollutionModule::D',
          ]
        )

        expect(definition.to_h).to match(fill_default(
          id: 'id',
          title: 'title',
          sources: [
            {
              source: 'AntipollutionModule::A',
              dependencies: [
                {
                  source: 'AntipollutionModule::B',
                  method_ids: [
                    {
                      name: 'call_c',
                      context: 'class',
                      paths: [
                        match(/tracer_class\.rb:\d+/),
                      ],
                    },
                  ],
                },
              ],
            },
            {
              source: 'AntipollutionModule::B',
              dependencies: [
                {
                  source: 'AntipollutionModule::C',
                  method_ids: [
                    {
                      name: 'call_d',
                      context: 'class',
                      paths: [
                        match(/tracer_class\.rb:\d+/),
                      ],
                    },
                  ],
                },
              ],
            },
            {
              source: 'AntipollutionModule::C',
              dependencies: [
                {
                  source: 'AntipollutionModule::D',
                  method_ids: [
                    {
                      name: 'name',
                      context: 'class',
                      paths: [
                        match(/tracer_class\.rb:\d+/),
                      ],
                    },
                  ],
                },
              ],
            },
            {
              source: 'AntipollutionModule::D',
            },
          ]
        ))
      end

      it 'traces tracer_class.rb with filter path' do
        definition = trace_fixture(
          'tracer_class.rb',
          module_set: [
            'AntipollutionModule::A',
            'AntipollutionModule::B',
            'AntipollutionModule::C',
            'AntipollutionModule::D',
          ],
          filter_method_id_path: ->(path) {
            path.gsub(fixture_path(''), '')
          }
        )

        paths = definition.sources.flat_map(&:dependencies).flat_map(&:method_ids).flat_map(&:paths)
        expect(paths).to all(match(/^tracer_class\.rb:\d+/))
      end

      it 'traces tracer_instance.rb' do
        definition = trace_fixture(
          'tracer_instance.rb',
          module_set: [
            'AntipollutionModule::A',
            'AntipollutionModule::B',
            'AntipollutionModule::C',
            'AntipollutionModule::D',
          ]
        )

        expect(definition.to_h).to match(fill_default(
          id: 'id',
          title: 'title',
          sources: [
            {
              source: 'AntipollutionModule::A',
              dependencies: [
                {
                  source: 'AntipollutionModule::B',
                  method_ids: [
                    {
                      name: 'call_c',
                      context: 'instance',
                      paths: [
                        match(/tracer_instance\.rb:\d+/),
                      ],
                    },
                    {
                      name: 'new',
                      context: 'class',
                      paths: [
                        match(/tracer_instance\.rb:\d+/),
                      ],
                    },
                  ],
                },
              ],
            },
            {
              source: 'AntipollutionModule::B',
              dependencies: [
                {
                  source: 'AntipollutionModule::C',
                  method_ids: [
                    {
                      name: 'call_d',
                      context: 'instance',
                      paths: [
                        match(/tracer_instance\.rb:\d+/),
                      ],
                    },
                    {
                      name: 'new',
                      context: 'class',
                      paths: [
                        match(/tracer_instance\.rb:\d+/),
                      ],
                    },
                  ],
                },
              ],
            },
            {
              source: 'AntipollutionModule::C',
              dependencies: [
                {
                  source: 'AntipollutionModule::D',
                  method_ids: [
                    {
                      name: 'name',
                      context: 'class',
                      paths: [
                        match(/tracer_instance\.rb:\d+/),
                      ],
                    },
                  ],
                },
              ],
            },
            {
              source: 'AntipollutionModule::D',
            },
          ]
        ))
      end

      it 'traces tracer_subclass.rb' do
        definition = trace_fixture(
          'tracer_subclass.rb',
          module_set: [
            'AntipollutionModule::A',
            'AntipollutionModule::D',
          ]
        )

        expect(definition.to_h).to match(fill_default(
          id: 'id',
          title: 'title',
          sources: [
            {
              source: 'AntipollutionModule::A',
              dependencies: [
                {
                  source: 'AntipollutionModule::B',
                  method_ids: [
                    {
                      name: 'call_c',
                      context: 'instance',
                      paths: [
                        match(/tracer_subclass\.rb:\d+/),
                      ],
                    },
                    {
                      name: 'new',
                      context: 'class',
                      paths: [
                        match(/tracer_subclass\.rb:\d+/),
                      ],
                    },
                  ],
                },
              ],
            },
            {
              source: 'AntipollutionModule::B',
              dependencies: [
                {
                  source: 'AntipollutionModule::C',
                  method_ids: [
                    {
                      name: 'call_d',
                      context: 'instance',
                      paths: [
                        match(/tracer_subclass\.rb:\d+/),
                      ],
                    },
                    {
                      name: 'new',
                      context: 'class',
                      paths: [
                        match(/tracer_subclass\.rb:\d+/),
                      ],
                    },
                  ],
                },
              ],
            },
            {
              source: 'AntipollutionModule::C',
              dependencies: [
                {
                  source: 'AntipollutionModule::D',
                  method_ids: [
                    {
                      name: 'new',
                      context: 'class',
                      paths: [
                        match(/tracer_subclass\.rb:\d+/),
                      ],
                    },
                  ],
                },
              ],
            },
            {
              source: 'AntipollutionModule::D',
            },
          ]
        ))
      end

      it 'traces tracer_separated_file.rb' do
        stub_const('::A', Class.new)
        stub_const('::B', Class.new)
        stub_const('::C', Class.new)

        definition = trace_fixture(
          'tracer_separated_file.rb',
          module_set: [
            '::A',
            '::C',
          ],
          target_files: [
            fixture_path('tracer_separated_file.rb'),
          ]
        )

        expect(definition.to_h).to match(fill_default(
          id: 'id',
          title: 'title',
          sources: [
            {
              source: 'A',
              dependencies: [
                {
                  source: 'C',
                  method_ids: [
                    {
                      name: 'name',
                      context: 'class',
                      paths: [
                        match(/tracer_separated_file\.rb:\d+/),
                      ],
                    },
                  ],
                },
              ],
            },
            {
              source: 'C',
            },
          ]
        ))
      end

      it 'traces tracer_deep_stack.rb' do
        definition = trace_fixture(
          'tracer_deep_stack.rb',
          module_set: [
            'AntipollutionModule::A',
            'AntipollutionModule::D',
          ]
        )

        expect(definition.to_h).to match(fill_default(
          id: 'id',
          title: 'title',
          sources: [
            {
              source: 'AntipollutionModule::A',
              dependencies: [
                {
                  source: 'AntipollutionModule::D',
                  method_ids: [
                    {
                      name: 'name',
                      context: 'class',
                      paths: [
                        match(/tracer_deep_stack\.rb:\d+/),
                      ],
                    },
                  ],
                },
              ],
            },
            {
              source: 'AntipollutionModule::D',
            },
          ]
        ))
      end

      # For optimize
      # it 'traces tracer_deep_stack.rb fast' do
      #   require 'benchmark'
      #
      #   without_trace = Benchmark.realtime do
      #     mod = Module.new
      #     k = Class.new
      #     k.include(mod)
      #     load(fixture_path('tracer_deep_stack.rb'), mod)
      #     k.allocate.send(:run)
      #   end
      #
      #   with_trace = Benchmark.realtime do
      #     # NOTE: Script need to define .run method
      #     script = fixture_path('tracer_deep_stack.rb')
      #     load script, AntipollutionModule
      #     antipollution_environment = AntipollutionKlass.allocate
      #
      #     tracer = described_class.new(
      #       id: 'id',
      #       title: 'title',
      #       module_set: [
      #         AntipollutionModule::A,
      #         AntipollutionModule::D,
      #       ]
      #     )
      #
      #     tracer.trace do
      #       antipollution_environment.send(:run)
      #     end
      #   end
      #
      #   puts "#{with_trace / without_trace} times slower"
      # end
    end
  end
end
