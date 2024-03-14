# frozen_string_literal: true

require 'diverdown'
require 'diverdown/web'
require 'rack/reloader'

use Rack::Reloader
run Diverdown::Web.new(definition_dir: ENV.fetch('DIVERDOWN_DIR'))
