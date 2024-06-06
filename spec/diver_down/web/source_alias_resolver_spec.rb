# frozen_string_literal: true

RSpec.describe DiverDown::Web::SourceAliasResolver do
  describe 'InstanceMethods' do
    describe '#resolve' do
      include DefinitionHelper

      let(:source_alias) { DiverDown::Web::Metadata::SourceAlias.new }

      it 'combined aliased source_names' do
        definition = DiverDown::Definition.from_hash(
          sources: [
            {
              source_name: 'Document',
              dependencies: [
                {
                  source_name: 'DocumentA',
                  method_ids: [
                    context: 'class',
                    name: 'call',
                    paths: [
                      'document_a.rb:9',
                    ],
                  ],
                },
              ],
            }, {
              source_name: 'DocumentA',
              dependencies: [
                {
                  source_name: 'User',
                  method_ids: [
                    context: 'class',
                    name: 'call',
                    paths: [
                      'user.rb:1',
                    ],
                  ],
                },
              ],
            }, {
              source_name: 'User',
              dependencies: [
                {
                  source_name: 'DocumentA',
                  method_ids: [
                    context: 'class',
                    name: 'call',
                    paths: [
                      'document_a.rb:9',
                    ],
                  ],
                },
              ],
            },
          ]
        )

        source_alias.update_alias('Document', ['DocumentA'])
        resolver = described_class.new(source_alias)
        resolved_definition = resolver.resolve(definition)

        expect(resolved_definition.to_h).to eq(fill_default(
          sources: [
            {
              source_name: 'Document',
              dependencies: [
                {
                  source_name: 'User',
                  method_ids: [
                    context: 'class',
                    name: 'call',
                    paths: [
                      'user.rb:1',
                    ],
                  ],
                },
              ],
            }, {
              source_name: 'User',
              dependencies: [
                {
                  source_name: 'Document',
                  method_ids: [
                    context: 'class',
                    name: 'call',
                    paths: [
                      'document_a.rb:9',
                    ],
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
