def run
  # like AnonymousController in rspec-rails
  anonymous_class = Class.new(A) do
    def self.name
      "Anonymous"
    end

    # defined as anonymous class
    def self.should_be_ignored
      B.should_be_ignored
    end
  end

  anonymous_class.should_be_ignored
  anonymous_class.should_be_traced
end

class A
  # defined as non-anonymous class
  def self.should_be_traced
    B.should_be_traced
  end
end

class B
  def self.should_be_traced = nil

  def self.should_be_ignored = nil
end
