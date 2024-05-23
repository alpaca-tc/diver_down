class B
  def self.call_c
    yield_self do
      C.call_d
    end
  end
end
