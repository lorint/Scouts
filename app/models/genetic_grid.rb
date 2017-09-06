class GeneticGrid
  attr_reader :is_interrupted
  def initialize(grid)
    @is_interrupted = false

    # We'll accept within 5% of perfect
    @minimum = grid.min * 1.05
    # puts "Our goal: #{@minimum}"
    @length = grid.pts.length
    @seg = (grid.pts.length * 0.3).ceil
    population_size = Math.sqrt(@length).ceil * 60
    @mby = (population_size / 20).ceil

    # 1.  Generate a random initial population of itineraries (tours).
    @population = []
    population_size.times do
      random_points = grid.pts.sort_by { rand }
      @population << {distance: distance(random_points), points: random_points}
    end
    population_sort
  end

  def interrupt
    self.top[:is_done] = true unless self.top.nil?
    @is_interrupted = true
  end

  def top
    @population.first
  end

  # Euclidean distance
  def distance(points)
    total = 0
    # Make it include the trip back home
    all_points = points + [points.first]
    @length.times do |i|
      # Pythagorean calculation of distance
      # [0] refers to the X, and [1] to the Y
      total += Math.sqrt((all_points[i][0] - all_points[i + 1][0]) ** 2 + (all_points[i][1] - all_points[i + 1][1]) ** 2)
    end
    total
  end

  def population_sort
    # 3.  Rank the population according to a fitness function.
    @population = @population.sort_by { |tour| tour[:distance] }
  end

  def solve
    start_time = Time.now
    # 5.  Keep going back to iterate until the best itinerary meets an exit criterion.
    last_best = nil
    Thread.new do
      while @is_interrupted == false && iterate()[:distance] > @minimum
        if last_best.nil? || last_best > @population.first[:distance]
          yield @population.first if block_given?
          last_best = @population.first[:distance]
        end
        # puts @population.first[:distance]
      end
      @population.first[:is_done] = true
      @population.first[:total_time] = Time.now - start_time
      yield @population.first if block_given?
    end
  end

  def iterate
    # 4.  Reduce the population to a prescribed size,
    #   in this case the 20 best solutions.
    @population = (@population[0..20] * @mby).map do |tour|
      # 2.  Replicate each itinerary with some variation.
      new_points = tour[:points].dup
      case rand(10)
      # 70% of the time we do a reverse mutation
      when 0..6
        # By default first cut somewhere up to 30% of the length...
        seg = rand(@seg)
        # ... and second cut after 70% of the length
        r = rand(@length - seg + 1)
        # Swap them around
        new_points[r, seg] = new_points[r, seg].reverse
      # 10% of the time we just "cut the deck" (pick a random place to start and place the points from there to the end on top)
      when 7
        new_points = new_points.slice!(rand(@length)..-1) + new_points
      # 20% of the time an exchange mutation
      when 8..9
        # Pick three random points
        r = []
        3.times { r << rand(@length)}
        r.sort!
        new_points = new_points[0...r[0]] + new_points[r[1]...r[2]] + new_points[r[0]...r[1]] + new_points[r[2]..-1]
      end
      {distance: distance(new_points), points: new_points}
    end
    population_sort
    @population.first
  end
end
