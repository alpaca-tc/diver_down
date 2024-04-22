# frozen_string_literal: true

module DiverDown
  module Helper
    # @param str [String]
    # @return [Module]
    def self.constantize(str)
      ::ActiveSupport::Inflector.constantize(str)
    end
  end
end
