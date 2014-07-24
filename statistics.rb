class Array
  def mean
    fail 'no data in array' if empty?
    inject(:+).fdiv(size)
  end

  def median
    fail 'no data in array' if empty?
    if size.odd?
      index = size.div(2)
      self[index]
    else
      right = size.div(2)
      left = right - 1
      [self[right], self[left]].mean
    end
  end
end

