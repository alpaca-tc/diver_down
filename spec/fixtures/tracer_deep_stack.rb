# frozen_string_literal: true

def run
  A.new.run
end

class A
  N = 100_000

  def run
    N.times do
      B.new.deep_stack
    end
  end
end

class B
  N = 100_000

  def deep_stack(i = 0)
    if i > N
      deep_stack(i + 1)
    else
      D.name
    end
  end
end

class D
end
