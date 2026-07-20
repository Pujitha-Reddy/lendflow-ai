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

ActiveRecord::Schema[8.1].define(version: 2026_07_20_214426) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "credit_profiles", force: :cascade do |t|
    t.integer "bankruptcies", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "credit_score", null: false
    t.decimal "debt_to_income", precision: 5, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_credit_profiles_on_user_id", unique: true
  end

  create_table "loan_applications", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "purpose", null: false
    t.string "status", default: "pending", null: false
    t.integer "term_months", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["status"], name: "index_loan_applications_on_status"
    t.index ["user_id"], name: "index_loan_applications_on_user_id"
  end

  create_table "loan_decisions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "decision", null: false
    t.decimal "interest_rate", precision: 5, scale: 2
    t.bigint "loan_application_id", null: false
    t.text "reason", null: false
    t.datetime "updated_at", null: false
    t.index ["loan_application_id"], name: "index_loan_decisions_on_loan_application_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "employment_status", null: false
    t.string "first_name", null: false
    t.decimal "income", precision: 12, scale: 2
    t.string "last_name", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "credit_profiles", "users"
  add_foreign_key "loan_applications", "users"
  add_foreign_key "loan_decisions", "loan_applications"
end
