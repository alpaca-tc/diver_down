# frozen_string_literal: true

require 'diver_down'
require 'diver_down/web'
require 'rack/reloader'

use Rack::Reloader
use DiverDown::Web::DevServerMiddleware, host: 'localhost', port: 5173 # Proxy to vite(pnpm run dev)
run DiverDown::Web.new(definition_dir: ENV.fetch('DIVER_DOWN_DIR'))
