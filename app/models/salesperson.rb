class Salesperson
  # Everyone sees the same grid (from this server anyway) at the same time
  @@grid = nil
  @@num_clients = 0

  # Singleton pattern -- have only one GeneticGrid around at a time
  def self.construct(size, callback)
    @@grid = nil if !@@grid.nil? && @@grid.is_interrupted
    if @@grid.nil? || @@grid.top[:is_done]
      @@num_clients = 0
      if callback.nil?
        @@grid = GeneticGrid.new(Grid.new(size))
        @@grid.solve
      else
        @@grid = GeneticGrid.new(Grid.new(size))
        @@grid.solve do |current|
          callback.call(current)
        end
      end
    end
    @@num_clients += 1
    @@grid
  end

  def self.deconstruct
    unless @@num_clients <= 0
      if (@@num_clients -= 1) <= 0
        @@grid.interrupt
      end
    end
  end

  def self.num_clients
    @@num_clients
  end

  def self.grid
    @@grid
  end
end
