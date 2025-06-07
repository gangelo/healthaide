class CreateFoods < ActiveRecord::Migration[8.0]
  def change
    create_table :foods do |t|
      t.string :food_name, null: false

      t.timestamps
    end

    add_index :foods, :food_name, unique: true
  end
end
