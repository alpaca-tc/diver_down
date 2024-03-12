# frozen_string_literal: true

load "#{__dir__}/tracer_separated_file/a.rb"

def run
  ::A.new.run
end

class ::B
  def self.call_c
    ::C.name
  end
end

class ::C
end
