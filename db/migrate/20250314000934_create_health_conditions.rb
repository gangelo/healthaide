class CreateHealthConditions < ActiveRecord::Migration[7.1]
  def change
    create_table :health_conditions do |t|
      t.string :health_condition_name, null: false, limit: 64

      t.timestamps
    end

    add_index :health_conditions, :health_condition_name, unique: true
  end
end
