def run
  A.class_call
end

class A
  def self.class_call
    B.class_call
  end
end

class B
  def self.class_call
    C.class_call
  end
end

class C
  def self.class_call
    D.class_call
  end
end

class D
  def self.class_call
    nil
  end
end
