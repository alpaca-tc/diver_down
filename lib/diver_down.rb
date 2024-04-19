# frozen_string_literal: true

require_relative 'diver_down/version'

module DiverDown
  class Error < StandardError; end

  DELIMITER = ','

  require 'diver_down/definition'
  require 'diver_down/helper'
  require 'diver_down/diver_down_ext'
end
