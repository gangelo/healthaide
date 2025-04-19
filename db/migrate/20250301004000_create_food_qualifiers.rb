class CreateFoodQualifiers < ActiveRecord::Migration[7.2]
  def change
    create_table :food_qualifiers do |t|
      t.string :qualifier_name, null: false
      t.timestamps
    end

    # Add unique index on qualifier_name
    add_index :food_qualifiers, :qualifier_name, unique: true
  end
end
