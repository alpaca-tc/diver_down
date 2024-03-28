# frozen_string_literal: true

require 'rack/proxy'
require 'websocket/driver'
require 'eventmachine'

module DiverDown
  class Web
    # For vite
    class DevServerMiddleware
      class HttpProxy < ::Rack::Proxy
        def initialize(_app = nil, host:, port:)
          @host = host
          @port = port

          super(nil, backend: "http://#{@host}:#{@port}", proxy_host: @host, proxy_port: @port, proxy_scheme: 'http')
        end
      end

      class WebSocketProxy
        attr_reader :env, :url

        def initialize(env, host:, port:)
          @env = env
          @url = "ws://#{host}:#{port}#{env['REQUEST_URI']}"
          @driver = WebSocket::Driver.rack(self)

          env['rack.hijack'].call
          @io = env['rack.hijack_io']

          EM.attach(@io, Reader) { |conn| conn.driver = @driver }

          @driver.start
        end

        # @param string [String]
        def write(string)
          @io.write(string)
        end

        module Reader
          attr_writer :driver

          # @param string [String]
          def receive_data(string)
            @driver.parse(string)
          end
        end
      end

      def initialize(app, host:, port:)
        @app = app
        @host = host
        @port = port
        @http_proxy = HttpProxy.new(@app, host: @host, port: @port)
      end

      # @param env [Hash]
      def call(env)
        request = Rack::Request.new(env)

        if WebSocket::Driver.websocket?(env)
          WebSocketProxy.new(env, host: @host, port: @port)
        elsif request.path.start_with?('/api')
          @app.call(env)
        else
          @http_proxy.call(env)
        end
      end
    end
  end
end
