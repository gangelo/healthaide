class CreateUserSupplements < ActiveRecord::Migration[7.2]
  def change
    create_table :user_supplements do |t|
      t.string :name
      t.integer :form
      t.integer :frequency
      t.string :dosage
      t.string :dosage_unit
      t.string :manufacturer
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
