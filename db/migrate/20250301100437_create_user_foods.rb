class CreateUserFoods < ActiveRecord::Migration[7.2]
  def change
    create_table :user_foods do |t|
      t.references :user, null: false, foreign_key: true
      t.references :food, null: false, foreign_key: true
      t.boolean :favorite, default: false

      t.timestamps
    end

    add_index :user_foods, [ :user_id, :food_id ], unique: true
  end
end
