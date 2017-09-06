class CreateScoutMeritBadges < ActiveRecord::Migration[5.1]
  def change
    create_table :scout_merit_badges do |t|
      t.references :scout, foreign_key: true
      t.references :merit_badge, foreign_key: true
      t.string :counselor

      t.timestamps
    end
  end
end
