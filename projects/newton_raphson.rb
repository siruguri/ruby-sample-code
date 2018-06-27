class SeriesSum
  attr_reader :start, :length, :end_value
  def initialize(length, start, _end)
    @length = length
    @start = start
    @end_value = _end
  end
  
  def function(x)
    constant = @start - @end_value
    (sum, _) = (1..@length).each.inject([constant, x]) do |(sum, previous_calculation), index|
      next_calculation = previous_calculation * x
      sum += @start * previous_calculation
      [sum, next_calculation]
    end

    sum
  end

  def derivative(x)
    (sum, _) = (1..@length).each.inject([0, 1]) do |(sum, previous_calculation), index|
      next_calculation = (index + 1) * previous_calculation * x
      sum += @start * previous_calculation
      [sum, next_calculation]
    end

    sum
  end
end
