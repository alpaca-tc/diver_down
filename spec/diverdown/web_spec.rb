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
      expect(last_response.body).to include('html')
    end
  end

  describe 'GET /definitions/:id.json' do
    it 'returns 404 if id is not found' do
      post '/definitions/combine.json', ids: 'unknown'
      expect(last_response.status).to eq(404)
    end

    it 'returns definition if id is found' do
      definition = Diverdown::Definition.new(
        id: SecureRandom.uuid,
        title: 'title',
        sources: [
          Diverdown::Definition::Source.new(
            source: 'a.rb'
          ),
        ]
      )
      store.set(definition)

      post '/definitions/combine.json', ids: [definition.id].join(Diverdown::DELIMITER)

      expect(last_response.status).to eq(200)
      expect(last_response.headers['content-type']).to eq('application/json')
      expect(last_response.body).to include('digraph')
    end

    it 'returns combined definition' do
      definition_1 = Diverdown::Definition.new(
        id: SecureRandom.uuid,
        title: 'title',
        sources: [
          Diverdown::Definition::Source.new(
            source: 'a.rb'
          ),
        ]
      )
      definition_2 = Diverdown::Definition.new(
        id: SecureRandom.uuid,
        title: 'second title',
        sources: [
          Diverdown::Definition::Source.new(
            source: 'b.rb'
          ),
        ]
      )
      store.set(definition_1)
      store.set(definition_2)

      post '/definitions/combine.json', ids: [definition_1.id, definition_2.id].join(Diverdown::DELIMITER)

      expect(last_response.status).to eq(200)
      expect(last_response.headers['content-type']).to eq('application/json')
      expect(last_response.body).to include('digraph')
    end
  end

  describe 'GET /sources/:source' do
    it 'returns 404 if source is not found' do
      get '/sources/unknown.json'

      expect(last_response.status).to eq(404)
    end

    it 'returns response if source is found' do
      definition_1 = Diverdown::Definition.new(
        id: SecureRandom.uuid,
        title: 'title',
        sources: [
          Diverdown::Definition::Source.new(
            source: 'a.rb'
          ),
        ]
      )
      definition_2 = Diverdown::Definition.new(
        id: SecureRandom.uuid,
        title: 'second title',
        sources: [
          Diverdown::Definition::Source.new(
            source: 'b.rb'
          ),
        ]
      )
      store.set(definition_1)
      store.set(definition_2)

      get '/sources/a.rb'

      expect(last_response.status).to eq(200)
    end
  end
end
