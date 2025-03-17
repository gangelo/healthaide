class CreateUserHealthGoals < ActiveRecord::Migration[7.1]
  def change
    create_table :user_health_goals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :health_goal, null: false, foreign_key: true
      t.integer :order_of_importance, null: false, default: 0
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :user_health_goals, [ :user_id, :health_goal_id ], unique: true
    add_index :user_health_goals, :deleted_at
  end
end
