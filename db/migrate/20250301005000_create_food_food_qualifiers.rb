class CreateFoodFoodQualifiers < ActiveRecord::Migration[7.2]
  def change
    create_table :food_food_qualifiers do |t|
      t.references :food, null: false, foreign_key: true
      t.references :food_qualifier, null: false, foreign_key: true
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :food_food_qualifiers, :deleted_at
    add_index :food_food_qualifiers, [ :food_id, :food_qualifier_id ], unique: true, name: 'idx_food_qualifier_unique'
  end
end
