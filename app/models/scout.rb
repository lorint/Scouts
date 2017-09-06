class Scout < ApplicationRecord
  belongs_to :rank

  has_many :scout_merit_badges
  has_many :merit_badges, through: :scout_merit_badges

  accepts_nested_attributes_for :scout_merit_badges
end
