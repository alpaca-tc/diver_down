# frozen_string_literal: true

RSpec.configure do |config|
  config.include(Module.new do
    # @param paths [Array<String>]
    # @return [String]
    def fixture_path(*paths)
      base = File.expand_path('../fixtures', __dir__)
      File.join(base, *paths)
    end
  end)
end
