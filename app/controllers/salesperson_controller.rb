class SalespersonController < ApplicationController
  def index
    @size = (params[:size] || 10).to_i
  end
end
