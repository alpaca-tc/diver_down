# frozen_string_literal: true

require 'diver_down'
require 'diver_down/web'
require 'rack/reloader'
require 'rack/contrib'

definition_dir = ENV.fetch('DIVER_DOWN_DIR')
metadata = DiverDown::Web::Metadata.new(ENV.fetch('DIVER_DOWN_METADATA'))

use Rack::Reloader
use Rack::JSONBodyParser
use DiverDown::Web::DevServerMiddleware, host: 'localhost', port: 5173 # Proxy to vite(pnpm run dev)
run DiverDown::Web.new(definition_dir:, metadata:)
