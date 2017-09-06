class MatchChannel < ApplicationCable::Channel
  def subscribed
    stream_from "match"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def keypress(data)
    keypresses = Rails.cache.fetch("match") do
      Hash.new(0)
    end
    keypresses["scout#{data["scout_id"]}"] += 1
    Rails.cache.write("match", keypresses)

    ActionCable.server.broadcast("match", keypresses)
  end
end
