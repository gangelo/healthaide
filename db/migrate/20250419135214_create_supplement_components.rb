class CreateSupplementComponents < ActiveRecord::Migration[7.2]
  def change
    create_table :supplement_components do |t|
      t.string :supplement_component_name, null: false
      t.string :amount, null: false
      t.string :unit, null: false
      t.references :user_supplement, null: false, foreign_key: true

      t.timestamps
    end
  end
end
