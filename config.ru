# frozen_string_literal: true

require 'diverdown'
require 'diverdown/web_application'
require 'rack/reloader'

use Rack::Reloader
run Diverdown::WebApplication.new(definition_dir: ENV['DIVERDOWN_DIR'] || 'tmp/definitions')
