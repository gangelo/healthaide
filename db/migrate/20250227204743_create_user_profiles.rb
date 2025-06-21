class CreateUserProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_profiles do |t|
      t.references :user, null: false, foreign_key: true
      # default: Ai::Provider::AI_PROVIDER_NONE (i.e. 0 = no_provider)
      t.integer :ai_provider, default: 0, null: false
      t.string :ai_provider_api_key
      t.string :ai_provider_model

      t.timestamps
    end
  end
end
