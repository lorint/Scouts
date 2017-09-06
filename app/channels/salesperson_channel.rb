class SalespersonChannel < ApplicationCable::Channel
  # Send out the current best grid as better solutions are found
  @@callback = Proc.new { |info|
    ActionCable.server.broadcast("salesperson", info)
  }

  def subscribed
    stream_from "salesperson"

    kick_it
  end

  def unsubscribed
    # When they leave, interrupt any in-progress sessions
    # that nobody else cares about
    Salesperson.deconstruct
  end

  def again(size)
    kick_it
  end

  private

  def kick_it
    # #construct is a singleton, so this only starts calculating if there's not one already going
    Salesperson.construct((params[:size] || 10).to_i, @@callback)
  end
end
