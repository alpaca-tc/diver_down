# frozen_string_literal: true

require 'diver_down'
require 'diver_down-web'
require 'diver_down-trace'

Dir['./spec/support/**/*.rb'].each { require(_1) }

RSpec.configure do |config|
  config.expose_dsl_globally = false
  config.raise_errors_for_deprecations!
  config.order = :random

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  unless ENV.fetch('CI', nil)
    config.filter_run :focus
    config.run_all_when_everything_filtered = true
  end
end
