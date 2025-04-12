class CreateFoods < ActiveRecord::Migration[7.2]
  def change
    create_table :foods do |t|
      t.string :food_name, null: false
      t.string :unique_signature
      t.timestamps
    end

    # Add index on unique_signature (without soft-deletion condition)
    add_index :foods, [ :food_name, :unique_signature ], unique: true
  end
end
