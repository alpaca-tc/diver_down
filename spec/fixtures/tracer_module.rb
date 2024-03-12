def run
  A.call_b
end

module A
  def self.call_b
    # Add blank comment to test line number
    B.call_c
  end
end

module B
  def self.call_c
    C.call_d
  end
end

module C
  def self.call_d
    D.name
  end
end

module D
end
