class CreateUserFoods < ActiveRecord::Migration[7.2]
  def change
    create_table :user_foods do |t|
      t.references :user, null: false, foreign_key: true
      t.references :food, null: false, foreign_key: true
      t.boolean :favorite, default: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :user_foods, :deleted_at
  end
end
