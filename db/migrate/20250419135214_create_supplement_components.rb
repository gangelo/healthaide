class CreateSupplementComponents < ActiveRecord::Migration[7.2]
  def change
    create_table :supplement_components do |t|
      t.string :name
      t.string :amount
      t.string :unit
      t.references :user_supplement, null: false, foreign_key: true

      t.timestamps
    end
  end
end
