# frozen_string_literal: true

require 'tmpdir'

RSpec.configure do |config|
  config.before do
    # Reset configuration before each test
    Diverdown.instance_variable_set(:@configuration, nil)
    Diverdown.configure do
      _1[:output_dir] = Dir.mktmpdir
    end
  end
end
