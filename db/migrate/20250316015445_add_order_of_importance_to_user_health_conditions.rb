class AddOrderOfImportanceToUserHealthConditions < ActiveRecord::Migration[7.2]
  def change
    add_column :user_health_conditions, :order_of_importance, :integer, null: false, default: 1
  end
end
