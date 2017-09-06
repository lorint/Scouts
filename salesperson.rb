require 'pry'
class Grid
   attr_reader :n, :pts, :min
   def initialize(n)
      raise ArgumentError unless Integer === n && n > 1
      @n = n
      @pts = []
      n.times do |i|
        x = i.to_f
        n.times { |j| pts << [x, j.to_f] }
      end
      # min is length of any shortest tour traversing the grid.
      @min = n * n
      # We need one diagonal if it's an odd number
      @min += Math::sqrt(2.0) - 1 if @n % 2 == 1
   end
end

class GeneticGrid
  def initialize(grid)
    @grid = grid.pts
    # We'll accept within 5% of perfect
    @minimum = grid.min * 1.02
    puts "Our goal: #{@minimum}"
    @length = @grid.length
    # Swapping around segments is up to 30% of the whole set
    @seg = (@grid.length * 0.3).ceil
    population_size = Math.sqrt(@length).ceil * 60
    @mby = (population_size / 20).ceil

    # 1.  Generate a random initial population of itineraries.
    @population = []
    population_size.times do
      random_grid = @grid.sort_by { rand }
      @population << {distance: distance(random_grid), grid: random_grid}
    end
    population_sort
  end

  # Euclidean distance
  def distance(grid)
    total = 0
    # Make it include the trip back home
    g = grid + [grid.first]
    @length.times do |i|
      # Pythagorean calculation of distance
      total += Math.sqrt((g[i][0] - g[i + 1][0]) ** 2 + (g[i][1] - g[i + 1][1]) ** 2)
    end
    total
  end

  def population_sort
    # 3.  Rank the population according to a fitness function.
    @population = @population.sort_by { |e| e[:distance] }
  end

  def solve
    # 5.  Keep going back to iterate until the best itinerary meets an exit criterion.
    while iterate()[:distance] > @minimum
      puts @population.first[:distance]
    end
    @population.first
  end

  def iterate
    # 4.  Reduce the population to a prescribed size,
    #   in this case the 20 best solutions.
    @population = (@population[0..20] * @mby).map do |grid|
      # 2.  Replicate each itinerary with some variation.
      new_grid = grid[:grid].dup
      case rand(10)
      # 70% of the time we do a reverse mutation
      when 0..6 #Guesses concerning these values
        # By default first cut somewhere up to 30% of the length...
        seg = rand(@seg)
        # ... and second cut after 70% of the length
        r = rand(@grid.length - seg + 1)
        # Swap them around
        new_grid[r, seg] = new_grid[r, seg].reverse
      # 10% of the time we just exchange 2 random segments
      when 7
        new_grid = new_grid.slice!(rand(@grid.length)..-1) + new_grid
      # 20% of the time an exchange mutation
      when 8..9
        r = []
        3.times { r << rand(@grid.length)}
        r.sort!
        new_grid = new_grid[0...r[0]] + new_grid[r[1]...r[2]] + new_grid[r[0]...r[1]] + new_grid[r[2]..-1]
      end
      {distance: distance(new_grid), grid: new_grid}
    end
    population_sort
    @population.first
  end
end

gridsize = ARGV[0] ? ARGV[0].to_i : (print "Grid size: "; STDIN.gets.to_i)
grid = GeneticGrid.new(Grid.new(gridsize)).solve

puts "In time #{grid[:distance]}:"
grid[:grid].each do |point|
  print "#{point[0].to_i},#{point[1].to_i} "
end
puts