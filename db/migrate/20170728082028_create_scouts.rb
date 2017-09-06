class CreateScouts < ActiveRecord::Migration[5.1]
  def change
    create_table :scouts do |t|
      t.string :name
      t.references :rank, foreign_key: true

      t.timestamps
    end
  end
end
