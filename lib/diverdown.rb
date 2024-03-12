# frozen_string_literal: true

require_relative 'diverdown/version'

module Diverdown
  class Error < StandardError; end

  require 'diverdown/definition'
  require 'diverdown/definition_store'
  require 'diverdown/indented_string_io'
  require 'diverdown/helper'

  DEFAULT_CONFIGURATION = {
    output_dir: '/tmp/output',
  }.freeze

  # @return [Hash]
  def self.configuration
    @configuration ||= DEFAULT_CONFIGURATION.dup
  end

  # @yield [Hash]
  def self.configure
    yield(configuration)
  end
end
