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

ActiveRecord::Schema[7.2].define(version: 2025_03_14_232505) do
  create_table "food_food_qualifiers", force: :cascade do |t|
    t.integer "food_id", null: false
    t.integer "food_qualifier_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_food_food_qualifiers_on_deleted_at"
    t.index ["food_id", "food_qualifier_id"], name: "idx_food_qualifier_unique", unique: true
    t.index ["food_id"], name: "index_food_food_qualifiers_on_food_id"
    t.index ["food_qualifier_id"], name: "index_food_food_qualifiers_on_food_qualifier_id"
  end

  create_table "food_qualifiers", force: :cascade do |t|
    t.string "qualifier_name", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_food_qualifiers_on_deleted_at"
  end

  create_table "foods", force: :cascade do |t|
    t.string "food_name", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_foods_on_deleted_at"
  end

  create_table "health_conditions", force: :cascade do |t|
    t.string "health_condition_name", limit: 64, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_health_conditions_on_deleted_at"
    t.index ["health_condition_name"], name: "index_health_conditions_on_health_condition_name", unique: true, where: "deleted_at IS NULL /*application='HealthAIde'*/ /*application='HealthAIde'*/"
  end

  create_table "health_goals", force: :cascade do |t|
    t.string "health_goal_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_foods", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "food_id", null: false
    t.boolean "favorite", default: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_user_foods_on_deleted_at"
    t.index ["food_id"], name: "index_user_foods_on_food_id"
    t.index ["user_id"], name: "index_user_foods_on_user_id"
  end

  create_table "user_health_condition_health_conditions", force: :cascade do |t|
    t.integer "user_health_condition_id", null: false
    t.integer "health_condition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["health_condition_id"], name: "idx_on_health_condition_id_2e0f4ca33b"
    t.index ["user_health_condition_id"], name: "idx_on_user_health_condition_id_4e44bada3d"
  end

  create_table "user_health_conditions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "health_condition_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_user_health_conditions_on_deleted_at"
    t.index ["health_condition_id"], name: "index_user_health_conditions_on_health_condition_id"
    t.index ["user_id", "health_condition_id"], name: "idx_user_health_conditions_unique", unique: true, where: "deleted_at IS NULL /*application='HealthAIde'*/ /*application='HealthAIde'*/ /*application='HealthAIde'*/ /*application='HealthAIde'*/ /*application='HealthAIde'*/ /*application='HealthAIde'*/ /*application='HealthAIde'*/ /*application='HealthAIde'*/ /*application='HealthAIde'*/ /*application='HealthAIde'*/"
    t.index ["user_id"], name: "index_user_health_conditions_on_user_id"
  end

  create_table "user_health_goals", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "health_goal_id", null: false
    t.integer "order_of_importance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_user_health_goals_on_deleted_at"
    t.index ["health_goal_id"], name: "index_user_health_goals_on_health_goal_id"
    t.index ["user_id"], name: "index_user_health_goals_on_user_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "food_food_qualifiers", "food_qualifiers"
  add_foreign_key "food_food_qualifiers", "foods"
  add_foreign_key "user_foods", "foods"
  add_foreign_key "user_foods", "users"
  add_foreign_key "user_health_condition_health_conditions", "health_conditions"
  add_foreign_key "user_health_condition_health_conditions", "user_health_conditions"
  add_foreign_key "user_health_conditions", "health_conditions"
  add_foreign_key "user_health_conditions", "users"
  add_foreign_key "user_health_goals", "health_goals"
  add_foreign_key "user_health_goals", "users"
end
