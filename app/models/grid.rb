class Grid
  attr_reader :n, :pts, :min
  def initialize(n)
    raise ArgumentError unless Integer === n && n > 1
    # Units along one side of the square grid
    @n = n
    @pts = []
    n.times do |x|
      n.times { |y| pts << [x.to_f, y.to_f] }
    end
    # min is length of any shortest tour traversing the grid.
    @min = n * n
    # We need one diagonal if it's an odd number
    @min += Math::sqrt(2.0) - 1 if @n % 2 == 1
  end
end
