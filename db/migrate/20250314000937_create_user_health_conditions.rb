class CreateUserHealthConditions < ActiveRecord::Migration[7.1]
  def change
    create_table :user_health_conditions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :health_condition, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :user_health_conditions, :deleted_at
    add_index :user_health_conditions, [ :user_id, :health_condition_id ], unique: true, where: "deleted_at IS NULL", name: 'idx_user_health_conditions_unique'
  end
end
