class CreateHealthConditions < ActiveRecord::Migration[7.1]
  def change
    create_table :health_conditions do |t|
      t.string :health_condition_name, null: false, limit: 64
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :health_conditions, :health_condition_name, unique: true, where: "deleted_at IS NULL"
    add_index :health_conditions, :deleted_at
  end
end
