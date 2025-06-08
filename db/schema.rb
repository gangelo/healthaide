# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_07_121645) do
  create_table "foods", force: :cascade do |t|
    t.string "food_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_name"], name: "index_foods_on_food_name", unique: true
  end

  create_table "health_conditions", force: :cascade do |t|
    t.string "health_condition_name", limit: 64, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["health_condition_name"], name: "index_health_conditions_on_health_condition_name", unique: true
  end

  create_table "health_goals", force: :cascade do |t|
    t.string "health_goal_name", limit: 64, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["health_goal_name"], name: "index_health_goals_on_health_goal_name", unique: true
  end

  create_table "medications", force: :cascade do |t|
    t.string "medication_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medication_name"], name: "index_medications_on_medication_name"
  end

  create_table "supplement_components", force: :cascade do |t|
    t.string "supplement_component_name", null: false
    t.string "amount", null: false
    t.string "unit", null: false
    t.integer "user_supplement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_supplement_id"], name: "index_supplement_components_on_user_supplement_id"
  end

  create_table "supplement_health_conditions", force: :cascade do |t|
    t.integer "user_supplement_id", null: false
    t.integer "health_condition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["health_condition_id"], name: "index_supplement_health_conditions_on_health_condition_id"
    t.index ["user_supplement_id"], name: "index_supplement_health_conditions_on_user_supplement_id"
  end

  create_table "supplement_health_goals", force: :cascade do |t|
    t.integer "user_supplement_id", null: false
    t.integer "health_goal_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["health_goal_id"], name: "index_supplement_health_goals_on_health_goal_id"
    t.index ["user_supplement_id"], name: "index_supplement_health_goals_on_user_supplement_id"
  end

  create_table "user_foods", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "food_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_id"], name: "index_user_foods_on_food_id"
    t.index ["user_id", "food_id"], name: "index_user_foods_on_user_id_and_food_id", unique: true
    t.index ["user_id"], name: "index_user_foods_on_user_id"
  end

  create_table "user_health_conditions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "health_condition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["health_condition_id"], name: "index_user_health_conditions_on_health_condition_id"
    t.index ["user_id", "health_condition_id"], name: "idx_user_health_conditions_unique", unique: true
    t.index ["user_id"], name: "index_user_health_conditions_on_user_id"
  end

  create_table "user_health_goals", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "health_goal_id", null: false
    t.integer "order_of_importance", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["health_goal_id"], name: "index_user_health_goals_on_health_goal_id"
    t.index ["user_id", "health_goal_id"], name: "index_user_health_goals_on_user_id_and_health_goal_id", unique: true
    t.index ["user_id"], name: "index_user_health_goals_on_user_id"
  end

  create_table "user_meal_prompts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "include_user_stats", default: true
    t.text "food_ids", default: "[]"
    t.text "health_condition_ids", default: "[]"
    t.text "health_goal_ids", default: "[]"
    t.text "supplement_ids", default: "[]"
    t.integer "meals_count", default: 3
    t.datetime "generated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_meal_prompts_on_user_id", unique: true
  end

  create_table "user_medications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "medication_id", null: false
    t.integer "frequency", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medication_id"], name: "index_user_medications_on_medication_id"
    t.index ["user_id", "medication_id"], name: "index_user_medications_on_user_id_and_medication_id", unique: true
    t.index ["user_id"], name: "index_user_medications_on_user_id"
  end

  create_table "user_stats", force: :cascade do |t|
    t.date "birthday"
    t.string "sex", limit: 1
    t.decimal "height", precision: 5, scale: 2
    t.decimal "muscle_fat_analysis_weight", precision: 6, scale: 2
    t.decimal "muscle_fat_analysis_skeletal_muscle_mass", precision: 6, scale: 2
    t.decimal "muscle_fat_analysis_body_fat_mass", precision: 6, scale: 2
    t.string "muscle_fat_analysis_cid"
    t.decimal "obesity_analysis_bmi", precision: 5, scale: 2
    t.decimal "obesity_analysis_percent_body_fat", precision: 5, scale: 2
    t.decimal "abdominal_obesity_analysis_waist_hip_ratio", precision: 4, scale: 2
    t.integer "abdominal_obesity_analysis_visceral_fat_level"
    t.decimal "comprehensive_analysis_basal_metabolic_rate", precision: 8, scale: 2
    t.string "body_balance_evaluation_upper_lower"
    t.decimal "body_composition_analysis_soft_lean_mass", precision: 6, scale: 2
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_stats_on_user_id", unique: true
  end

  create_table "user_supplements", force: :cascade do |t|
    t.string "user_supplement_name", null: false
    t.integer "form", null: false
    t.integer "frequency", null: false
    t.string "dosage"
    t.string "dosage_unit"
    t.string "manufacturer"
    t.string "notes", limit: 256
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_supplements_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", limit: 64, default: "", null: false
    t.string "last_name", limit: 64, default: "", null: false
    t.string "username", limit: 64, default: "", null: false
    t.string "email", limit: 320, default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "supplement_components", "user_supplements"
  add_foreign_key "supplement_health_conditions", "health_conditions"
  add_foreign_key "supplement_health_conditions", "user_supplements"
  add_foreign_key "supplement_health_goals", "health_goals"
  add_foreign_key "supplement_health_goals", "user_supplements"
  add_foreign_key "user_foods", "foods"
  add_foreign_key "user_foods", "users"
  add_foreign_key "user_health_conditions", "health_conditions"
  add_foreign_key "user_health_conditions", "users"
  add_foreign_key "user_health_goals", "health_goals"
  add_foreign_key "user_health_goals", "users"
  add_foreign_key "user_meal_prompts", "users"
  add_foreign_key "user_medications", "medications"
  add_foreign_key "user_medications", "users"
  add_foreign_key "user_stats", "users"
  add_foreign_key "user_supplements", "users"
end
