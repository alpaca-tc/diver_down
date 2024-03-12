def run
  A.call_b
end

class A
  def self.call_b
    B.call_c
  end
end

class B
  def self.call_c
    C.call_d
  end
end

class C
  def self.call_d
    D.name
  end
end

class D
end
