# frozen_string_literal: true

require 'rack'
require 'yaml'

module Diverdown
  class Web
    WEB_DIR = File.expand_path('../../web', __dir__)

    require 'diverdown/web/action'
    require 'diverdown/web/definition_to_dot'
    require 'diverdown/web/concurrency_worker'
    require 'diverdown/web/definition_enumerator'
    require 'diverdown/web/bit_id'

    # @param definition_dir [String]
    # @param store [Diverdown::DefinitionStore]
    def initialize(definition_dir:, store: Diverdown::DefinitionStore.new)
      @definition_dir = definition_dir
      @store = store
      @files_server = Rack::Files.new(File.join(WEB_DIR))
    end

    # @param env [Hash]
    # @return [Array[Integer, Hash, Array]]
    def call(env)
      request = Rack::Request.new(env)
      action = Diverdown::Web::Action.new(store: @store, request:)

      load_store if @store.empty?

      case [request.request_method, request.path]
      # in ['GET', %r{\A/definitions\.json\z}]
      #   page = request.params['page']&.to_i || 1
      #   action.definitions(page)
      in ['GET', %r{\A/api/definitions/(?<bit_id>\d+)\.json\z}]
        bit_id = Regexp.last_match[:bit_id].to_i
        action.combine_definitions(bit_id)
      in ['GET', %r{\A/api/sources/(?<source>.+)\.json\z}]
        source = Regexp.last_match[:source]
        action.source(source)
      in ['GET', '/']
        serve_file_or_dev_server(env.merge('PATH_INFO' => '/index.html'))
      else
        serve_file_or_dev_server(env)
      end
    end

    private

    def serve_file_or_dev_server(env)
      if ENV['DIVERDOWN_DEV']
        proxy_dev_server(env)
      else
        @files_server.call(env)
      end
    end

    def proxy_dev_server(env)
      require 'net/http'

      request = Net::HTTP::Get.new(env['PATH_INFO'])

      env.each do |key, value|
        next unless key.start_with?('HTTP_')

        formatted_key = key.sub(/^HTTP_/, '').split('_').map(&:downcase).join('-')
        request[formatted_key] = value
      end

      request['host'] = 'localhost'

      # Request to vite(`pnpm run vite`)
      response = Net::HTTP.start(request['host'], ENV.fetch('DIVERDOWN_PORT', 5173).to_i) do |http|
        http.request(Net::HTTP::Get.new(env['PATH_INFO']))
      end

      response_headers = {}
      response.each_header do |key, value|
        response_headers[key] = value
      end

      [response.code.to_i, response_headers, [response.body]]
    end

    def load_store
      # TODO: Optimize load yaml
      # TODO: How to implement packages and modules...
      # TODO: Loading all yaml is slow. Need to filter to load only wanted yaml.
      files = Dir[File.join(@definition_dir, '**', '*.msgpack')].sort.first(10)

      concurrency_worker = Diverdown::Web::ConcurrencyWorker.new(concurrency: 30)
      concurrency_worker.run(files) do |path|
        hash = Diverdown::Helper.deep_symbolize_keys(MessagePack.unpack(File.binread(path)))
        definition = Diverdown::Definition.from_hash(hash)
        @store.set(definition)
      end

      puts 'store loaded!'
    end
  end
end
