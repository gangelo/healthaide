class CreateUserMedications < ActiveRecord::Migration[8.0]
  def change
    create_table :user_medications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :medication, null: false, foreign_key: true
      t.integer :frequency, null: false

      t.timestamps
    end

    add_index :user_medications, [ :user_id, :medication_id ], unique: true
  end
end
