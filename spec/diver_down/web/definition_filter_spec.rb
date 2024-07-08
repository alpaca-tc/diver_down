# frozen_string_literal: true

RSpec.describe DiverDown::Web::DefinitionFilter do
  describe 'InstanceMethods' do
    describe '#resolve' do
      include DefinitionHelper

      let(:metadata) { DiverDown::Web::Metadata.new(Tempfile.new(['test', '.yaml']).path) }

      it 'filters sources and dependencies by modules' do
        definition = DiverDown::Definition.from_hash(
          sources: [
            {
              source_name: 'A::Employee',
              dependencies: [
                {
                  source_name: 'B::User',
                }, {
                  source_name: 'A::BankAccount',
                },
              ],
            }, {
              source_name: 'B::Billing',
            }, {
              source_name: 'B::User',
            }, {
              source_name: 'A::BankAccount',
              dependencies: [
                {
                  source_name: 'A::Employee',
                },
              ],
            }, {
              source_name: 'C::BankAccount',
            }, {
              source_name: 'User',
            },
          ]
        )

        definition.sources.each do |source|
          modulee, *other = source.source_name.split('::')
          metadata.source(source.source_name).module = modulee unless other.empty?
        end

        expect(described_class.new(metadata, modules: []).filter(definition).to_h).to eq(definition.to_h)

        expect(described_class.new(metadata, modules: [nil]).filter(definition).to_h).to eq(fill_default(
          sources: [
            {
              source_name: 'User',
            },
          ]
        ))

        expect(described_class.new(metadata, modules: ['A']).filter(definition).to_h).to eq(fill_default(
          sources: [
            {
              source_name: 'A::Employee',
              dependencies: [
                {
                  source_name: 'A::BankAccount',
                },
              ],
            }, {
              source_name: 'A::BankAccount',
              dependencies: [
                {
                  source_name: 'A::Employee',
                },
              ],
            },
          ]
        ))

        expect(described_class.new(metadata, modules: ['A', 'B']).filter(definition).to_h).to eq(fill_default(
          sources: [
            {
              source_name: 'A::Employee',
              dependencies: [
                {
                  source_name: 'B::User',
                }, {
                  source_name: 'A::BankAccount',
                },
              ],
            }, {
              source_name: 'B::Billing',
            }, {
              source_name: 'B::User',
            }, {
              source_name: 'A::BankAccount',
              dependencies: [
                {
                  source_name: 'A::Employee',
                },
              ],
            },
          ]
        ))

        expect(described_class.new(metadata, modules: ['C']).filter(definition).to_h).to eq(fill_default(
          sources: [
            {
              source_name: 'C::BankAccount',
            },
          ]
        ))
      end

      it 'filters sources and dependencies by modules and external module calls' do
        definition = DiverDown::Definition.from_hash(
          sources: [
            {
              source_name: 'A::Employee',
              dependencies: [
                {
                  source_name: 'B::User',
                }, {
                  source_name: 'A::BankAccount',
                },
              ],
            }, {
              source_name: 'B::Billing',
            }, {
              source_name: 'B::User',
            }, {
              source_name: 'A::BankAccount',
              dependencies: [
                {
                  source_name: 'A::Employee',
                },
              ],
            }, {
              source_name: 'C::BankAccount',
            },
          ]
        )

        definition.sources.each do |source|
          modulee, *last = source.source_name.split('::')
          metadata.source(source.source_name).module = modulee unless last.empty?
        end

        expect(described_class.new(metadata, modules: [], remove_internal_sources: true).filter(definition).to_h).to eq(fill_default(
          sources: [
            {
              source_name: 'A::Employee',
              dependencies: [
                {
                  source_name: 'B::User',
                },
              ],
            }, {
              source_name: 'B::User',
            },
          ]
        ))

        expect(described_class.new(metadata, modules: ['A'], remove_internal_sources: true).filter(definition).to_h).to eq(fill_default({}))

        expect(described_class.new(metadata, modules: ['A', 'B'], remove_internal_sources: true).filter(definition).to_h).to eq(fill_default(
          sources: [
            {
              source_name: 'A::Employee',
              dependencies: [
                {
                  source_name: 'B::User',
                },
              ],
            }, {
              source_name: 'B::User',
            },
          ]
        ))

        expect(described_class.new(metadata, modules: ['C'], remove_internal_sources: true).filter(definition).to_h).to eq(fill_default({}))
      end

      it 'filters sources and dependencies by modules and focus_modules and external module calls' do
        definition = DiverDown::Definition.from_hash(
          sources: [
            {
              source_name: 'A::User',
              dependencies: [
                {
                  source_name: 'B::User',
                },
              ],
            }, {
              source_name: 'B::User',
              dependencies: [
                {
                  source_name: 'C::User',
                },
              ],
            }, {
              source_name: 'C::User',
            },
          ]
        )

        definition.sources.each do |source|
          modulee, *last = source.source_name.split('::')
          metadata.source(source.source_name).module = modulee unless last.empty?
        end

        expect(described_class.new(metadata, focus_modules: [], modules: ['A', 'B', 'C'], remove_internal_sources: true).filter(definition).to_h).to eq(fill_default(
          sources: [
            {
              source_name: 'A::User',
              dependencies: [
                {
                  source_name: 'B::User',
                },
              ],
            }, {
              source_name: 'B::User',
              dependencies: [
                {
                  source_name: 'C::User',
                },
              ],
            }, {
              source_name: 'C::User',
            },
          ]
        ))

        expect(described_class.new(metadata, focus_modules: ['A'], modules: ['A', 'B', 'C'], remove_internal_sources: true).filter(definition).to_h).to eq(fill_default(
          sources: [
            {
              source_name: 'A::User',
              dependencies: [
                {
                  source_name: 'B::User',
                },
              ],
            }, {
              source_name: 'B::User',
            }, {
              source_name: 'C::User',
            },
          ]
        ))
      end
    end
  end
end
