class ScoutsController < ApplicationController
  def index
    @scouts = Scout.all
    @scout = Scout.new
  end

  def create
    Scout.create(scout_params)
    redirect_to scouts_path
  end

  def edit
    @scout = Scout.find(params[:id])
  end
  def update
    Scout.find(params[:id]).update(scout_params)
    redirect_to scouts_path
  end

  private

  def scout_params
    params.require(:scout).permit(:name, :rank_id,
      scout_merit_badges_attributes: [:id, :counselor],
      merit_badge_ids: [])
  end
end
