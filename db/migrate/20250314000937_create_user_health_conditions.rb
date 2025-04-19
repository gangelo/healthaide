class CreateUserHealthConditions < ActiveRecord::Migration[7.1]
  def change
    create_table :user_health_conditions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :health_condition, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_health_conditions, [ :user_id, :health_condition_id ], unique: true, name: 'idx_user_health_conditions_unique'
  end
end
