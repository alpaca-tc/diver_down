class C
  def self.call_d
    yield_self do
      yield_self do
        yield_self do
          D.call_name
        end
      end
    end
  end
end
