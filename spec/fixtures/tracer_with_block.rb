load "#{__dir__}/tracer_with_block/b.rb"
load "#{__dir__}/tracer_with_block/c.rb"
load "#{__dir__}/tracer_with_block/d.rb"

def run
  A.call_b
end

class A
  def self.call_b
    yield_self do
      B.call_c
    end
  end
end
