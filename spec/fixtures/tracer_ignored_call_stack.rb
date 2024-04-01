def run
  A.class_call
  # Isolated.class_call

  # A.new.instance_call
  # Isolated.new.instance_call
end

class A
  def self.class_call
    B.class_call
    C.class_call
    D.class_call
  end
end

class B
  def self.class_call
    D.class_call
  end
end

class C < B
end

class D
  def self.class_call
    nil
  end
end
