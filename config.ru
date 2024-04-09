# frozen_string_literal: true

require 'diver_down'
require 'diver_down/web'
require 'rack/reloader'
require 'rack/contrib'

definition_dir = ENV.fetch('DIVER_DOWN_DIR')
module_store = DiverDown::Web::ModuleStore.new(ENV.fetch('DIVER_DOWN_MODULE_STORE'))

use Rack::Reloader
use Rack::JSONBodyParser
use DiverDown::Web::DevServerMiddleware, host: 'localhost', port: 5173 # Proxy to vite(pnpm run dev)
run DiverDown::Web.new(definition_dir:, module_store:)
