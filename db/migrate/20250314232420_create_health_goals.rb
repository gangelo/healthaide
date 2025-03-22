class CreateHealthGoals < ActiveRecord::Migration[7.1]
  def change
    create_table :health_goals do |t|
      t.string :health_goal_name, null: false

      t.timestamps
    end

    add_index :health_goals, :health_goal_name, unique: true
  end
end
