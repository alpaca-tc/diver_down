# frozen_string_literal: true

RSpec.configure do |config|
  config.after do
    # Remove class variable cache
    DiverDown::Web.remove_instance_variable(:@store) if DiverDown::Web.instance_variable_defined?(:@store)
  end
end
