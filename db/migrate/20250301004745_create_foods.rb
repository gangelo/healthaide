class CreateFoods < ActiveRecord::Migration[7.2]
  def change
    create_table :foods do |t|
      t.string :food_name, null: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :foods, :deleted_at
  end
end
