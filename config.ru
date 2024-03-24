# frozen_string_literal: true

require 'diverdown'
require 'diverdown/web'
require 'rack/reloader'

use Rack::Reloader
use Diverdown::Web::DevServerMiddleware, host: 'localhost', port: 5173 # Proxy to vite(pnpm run dev)
run Diverdown::Web.new(definition_dir: ENV.fetch('DIVERDOWN_DIR'))
