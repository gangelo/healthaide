class CreateMedications < ActiveRecord::Migration[8.0]
  def change
    create_table :medications do |t|
      t.string :medication_name

      t.timestamps
    end
    add_index :medications, :medication_name
  end
end
