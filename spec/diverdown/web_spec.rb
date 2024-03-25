# frozen_string_literal: true

RSpec.describe Diverdown::Web do
  include Rack::Test::Methods

  def app
    @app ||= described_class.new(definition_dir:, store:)
  end

  let(:definition_dir) do
    Dir.mktmpdir
  end

  let(:store) do
    Diverdown::DefinitionStore.new
  end

  describe 'GET /' do
    it 'returns body' do
      get '/'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'GET /api/definitions.json' do
    it 'returns [] if store is blank' do
      get '/api/definitions.json'

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to eq({
        'definitions' => [],
        'pagination' => {
          'current_page' => 1,
          'total_pages' => 1,
          'total_count' => 0,
          'per' => 100,
        },
      })
    end

    it 'returns definition if store has one definition' do
      definition = Diverdown::Definition.new(
        title: 'title',
        sources: [
          Diverdown::Definition::Source.new(
            source_name: 'a.rb'
          ),
        ]
      )
      store.set(definition)

      get '/api/definitions.json'

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to eq({
        'definitions' => [
          {
            'id' => 1,
            'title' => 'title',
            'definition_group' => nil,
          },
        ],
        'pagination' => {
          'current_page' => 1,
          'total_pages' => 1,
          'total_count' => 1,
          'per' => 100,
        },
      })
    end

    describe 'title' do
      def assert_title(title, expected_ids)
        get "/api/definitions.json?title=#{title}"

        definitions = JSON.parse(last_response.body)['definitions']
        ids = definitions.map { _1['id'] }

        expect(ids).to match_array(expected_ids), -> {
          "title: #{title.inspect}\n" \
          "expected_ids: #{expected_ids.inspect}\n" \
          "actual_ids: #{ids.inspect}"
        }
      end

      it 'filters definitions by title=value' do
        definition_1 = Diverdown::Definition.new(
          title: '01234',
          sources: [
            Diverdown::Definition::Source.new(
              source_name: 'a.rb'
            ),
          ]
        )
        definition_2 = Diverdown::Definition.new(
          title: '56789',
          sources: [
            Diverdown::Definition::Source.new(
              source_name: 'b.rb'
            ),
          ]
        )

        definition_1_id, definition_2_id = store.set(definition_1, definition_2)

        assert_title 'unknown', []

        # Strict match
        assert_title '01234', [definition_1_id]
        assert_title '56789', [definition_2_id]
        assert_title 'a.rb', []

        # like match
        assert_title '0', [definition_1_id]
        assert_title '1', [definition_1_id]
        assert_title 'a', []
      end
    end

    describe 'source' do
      def assert_source(source, expected_ids)
        get "/api/definitions.json?source=#{source}"

        definitions = JSON.parse(last_response.body)['definitions']
        ids = definitions.map { _1['id'] }

        expect(ids).to match_array(expected_ids), -> {
          "source: #{source.inspect}\n" \
          "expected_ids: #{expected_ids.inspect}\n" \
          "actual_ids: #{ids.inspect}"
        }
      end

      it 'filters definitions by source=value' do
        definition_1 = Diverdown::Definition.new(
          title: '01234',
          sources: [
            Diverdown::Definition::Source.new(
              source_name: 'a.rb'
            ),
          ]
        )
        definition_2 = Diverdown::Definition.new(
          title: '56789',
          sources: [
            Diverdown::Definition::Source.new(
              source_name: 'b.rb'
            ),
          ]
        )

        definition_1_id, definition_2_id = store.set(definition_1, definition_2)

        assert_source 'unknown', []

        # Strict match
        assert_source '01234', []
        assert_source 'a.rb', [definition_1_id]
        assert_source 'b.rb', [definition_2_id]

        # like match
        assert_source '0', []
        assert_source 'a', [definition_1_id]
        assert_source 'b.', [definition_2_id]
      end
    end
  end

  describe 'GET /api/definitions/:id.json' do
    it 'returns 404 if id is not found' do
      get '/definitions/0.json'
      expect(last_response.status).to eq(404)
    end

    it 'returns definition if id is found' do
      definition = Diverdown::Definition.new(
        title: 'title',
        sources: [
          Diverdown::Definition::Source.new(
            source_name: 'a.rb'
          ),
        ]
      )
      bit_ids = store.set(definition)

      get "/api/definitions/#{bit_ids[0]}.json"

      expect(last_response.status).to eq(200)
      expect(last_response.headers['content-type']).to eq('application/json')
      expect(last_response.body).to include('digraph')
    end

    it 'returns combined definition' do
      definition_1 = Diverdown::Definition.new(
        title: 'title',
        sources: [
          Diverdown::Definition::Source.new(
            source_name: 'a.rb'
          ),
        ]
      )
      definition_2 = Diverdown::Definition.new(
        title: 'second title',
        sources: [
          Diverdown::Definition::Source.new(
            source_name: 'b.rb'
          ),
        ]
      )
      bit_ids = store.set(definition_1, definition_2)

      get "/api/definitions/#{bit_ids.inject(0, &:|)}.json"

      expect(last_response.status).to eq(200)
      expect(last_response.headers['content-type']).to eq('application/json')
      expect(last_response.body).to include('digraph')
    end
  end

  describe 'GET /api/sources/:source.json' do
    it 'returns 404 if source is not found' do
      get '/api/sources/unknown.json'

      expect(last_response.status).to eq(404)
    end

    it 'returns response if source is found' do
      definition_1 = Diverdown::Definition.new(
        title: 'title',
        sources: [
          Diverdown::Definition::Source.new(
            source_name: 'a.rb'
          ),
        ]
      )
      definition_2 = Diverdown::Definition.new(
        title: 'second title',
        sources: [
          Diverdown::Definition::Source.new(
            source_name: 'b.rb'
          ),
        ]
      )
      store.set(definition_1)
      store.set(definition_2)

      get '/api/sources/a.rb.json'

      expect(last_response.status).to eq(200)
    end
  end
end
