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

ActiveRecord::Schema[8.1].define(version: 2026_03_17_120735) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "shopping_list_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.boolean "checked", default: false, null: false
    t.datetime "created_at", null: false
    t.text "name"
    t.integer "priority", default: 0, null: false
    t.decimal "quantity", precision: 8, scale: 2, default: "0.0"
    t.uuid "shopping_list_id", null: false
    t.integer "unit", default: 0
    t.datetime "updated_at", null: false
    t.index ["shopping_list_id"], name: "index_shopping_list_items_on_shopping_list_id"
  end

  create_table "shopping_lists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "note"
    t.uuid "owner_id", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_shopping_lists_on_owner_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "session_version", default: 1, null: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "shopping_list_items", "shopping_lists", on_update: :cascade, on_delete: :cascade
  add_foreign_key "shopping_lists", "users", column: "owner_id"
end
