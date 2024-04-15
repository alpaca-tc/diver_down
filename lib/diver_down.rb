# frozen_string_literal: true

require_relative 'diver_down/version'

module DiverDown
  class Error < StandardError; end

  DELIMITER = ','
  LIB_DIR = __dir__

  require 'diver_down/definition'
  require 'diver_down/helper'
end
