class CreateRanks < ActiveRecord::Migration[5.1]
  def change
    create_table :ranks do |t|
      t.string :name

      t.timestamps
    end
  end
end
