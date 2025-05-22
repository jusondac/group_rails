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

ActiveRecord::Schema[8.0].define(version: 2025_05_23_105103) do
  create_table "communities", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "private", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_communities_on_name", unique: true
  end

  create_table "event_participants", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "user_id", null: false
    t.string "status", default: "attending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_participants_on_event_id"
    t.index ["user_id", "event_id"], name: "index_event_participants_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_event_participants_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "start_date", null: false
    t.datetime "end_date"
    t.string "location"
    t.boolean "private", default: false
    t.integer "community_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_events_on_community_id"
    t.index ["created_by_id"], name: "index_events_on_created_by_id"
  end

  create_table "finance_settings", force: :cascade do |t|
    t.integer "community_id", null: false
    t.decimal "amount", precision: 10, scale: 2, default: "0.0"
    t.string "frequency", default: "monthly"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_finance_settings_on_community_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "community_id", null: false
    t.string "role", default: "member"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_memberships_on_community_id"
    t.index ["user_id", "community_id"], name: "index_memberships_on_user_id_and_community_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "membership_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "paid_at"
    t.datetime "due_date", null: false
    t.string "status", default: "pending"
    t.string "period"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id"], name: "index_payments_on_membership_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "event_participants", "events"
  add_foreign_key "event_participants", "users"
  add_foreign_key "events", "communities"
  add_foreign_key "events", "users", column: "created_by_id"
  add_foreign_key "finance_settings", "communities"
  add_foreign_key "memberships", "communities"
  add_foreign_key "memberships", "users"
  add_foreign_key "payments", "memberships"
  add_foreign_key "sessions", "users"
end
