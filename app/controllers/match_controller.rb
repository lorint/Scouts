class MatchController < ApplicationController
  def index
    # Not really a list of matches, but just a landing page to have a match

    @scout = Scout.find(params[:scout_id])
    @keypresses = Rails.cache.fetch("keypresses") do
      Hash.new(0)
    end
    @scout_names = Scout.all.inject({}) {|s, v| s["scout#{v.id}"] = v.name; s}
  end
end
