module Util
  def time
    t = Time.now
    yield
    Time.now - t
  end
  module_function :time
end

