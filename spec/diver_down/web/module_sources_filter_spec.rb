# frozen_string_literal: true

RSpec.describe DiverDown::Web::ModuleSourcesFilter do
  describe 'InstanceMethods' do
    describe '#resolve' do
      include DefinitionHelper

      let(:metadata) { DiverDown::Web::Metadata.new(Tempfile.new(['test', '.yaml']).path) }

      it 'filters sources and dependencies by modules' do
        definition = DiverDown::Definition.from_hash(
          sources: [
            {
              source_name: 'Employee',
              dependencies: [
                {
                  source_name: 'User',
                  method_ids: [
                    {
                      context: 'class',
                      name: 'call',
                      paths: [
                        'user.rb:1',
                      ],
                    },
                  ],
                }, {
                  source_name: 'BankAccount',
                  method_ids: [
                    {
                      context: 'class',
                      name: 'call',
                      paths: [
                        'user.rb:1',
                      ],
                    },
                  ],
                },
              ],
            }, {
              source_name: 'Billing',
            },
          ]
        )

        instance = described_class.new(metadata)

        metadata.source('Employee').modules = ['global']
        metadata.source('User').modules = ['global']
        new_definition = instance.filter(definition, modules: ['global'])

        expect(new_definition.to_h).to eq(fill_default(
          sources: [
            {
              source_name: 'Employee',
              dependencies: [
                {
                  source_name: 'User',
                  method_ids: [
                    {
                      context: 'class',
                      name: 'call',
                      paths: [
                        'user.rb:1',
                      ],
                    },
                  ],
                },
              ],
            },
          ]
        ))
      end
    end
  end
end
