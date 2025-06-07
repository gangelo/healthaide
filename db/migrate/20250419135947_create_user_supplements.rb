class CreateUserSupplements < ActiveRecord::Migration[8.0]
  def change
    create_table :user_supplements do |t|
      t.string :user_supplement_name, null: false
      t.integer :form, null: false
      t.integer :frequency, null: false
      t.string :dosage
      t.string :dosage_unit
      t.string :manufacturer
      t.string :notes, limit: 256
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
