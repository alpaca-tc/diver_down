# frozen_string_literal: true

require 'msgpack'
require_relative 'diver_down/version'

module DiverDown
  class Error < StandardError; end

  DELIMITER = ','

  require 'diver_down/definition'
  require 'diver_down/definition_store'
  require 'diver_down/definition_loader'
  require 'diver_down/indented_string_io'
  require 'diver_down/helper'
end
