class CreateFoodQualifiers < ActiveRecord::Migration[7.2]
  def change
    create_table :food_qualifiers do |t|
      t.string :qualifier_name, null: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :food_qualifiers, :deleted_at
  end
end
