def run
  class_a = Class.new(A) do
    def self.name = nil
  end

  class_a.call_b
end

class A
  def self.call_b
    B.call_b
  end
end

class B
  def self.call_b = ''
end
