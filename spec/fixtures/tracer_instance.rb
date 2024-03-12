def run
  A.new.call_b
end

class A
  def call_b
    B.new.call_c
  end
end

class B
  def call_c
    C.new.call_d
  end
end

class C
  def call_d
    D.name
  end
end

class D
end
