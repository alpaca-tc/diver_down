# frozen_string_literal: true

require_relative 'diverdown/version'

module Diverdown
  class Error < StandardError; end

  DELIMITER = ','

  require 'diverdown/definition'
  require 'diverdown/definition_store'
  require 'diverdown/indented_string_io'
  require 'diverdown/helper'
end
