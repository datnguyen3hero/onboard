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

ActiveRecord::Schema[7.1].define(version: 2026_01_12_094351) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "alert_subscriptions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "alert_id", null: false
    t.boolean "email_enabled", default: true
    t.boolean "push_enabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_alert_subscriptions_on_alert_id"
    t.index ["user_id", "alert_id"], name: "index_alert_subscriptions_on_user_id_and_alert_id", unique: true
    t.index ["user_id"], name: "index_alert_subscriptions_on_user_id"
  end

  create_table "alerts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "alert_type", null: false
    t.string "title", null: false
    t.string "body"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at", precision: nil
    t.datetime "acknowledged_at"
    t.datetime "resolved_at"
    t.string "severity", default: "medium", null: false
    t.integer "status", default: 0, null: false
    t.index ["alert_type"], name: "index_alerts_on_alert_type"
    t.index ["severity", "created_at"], name: "index_alerts_on_severity_and_created_at"
    t.index ["title"], name: "index_alerts_on_title", unique: true
  end

  create_table "user_login_log", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.boolean "success", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_login_log_on_user_id"
  end

  create_table "user_profiles", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "full_name", null: false
    t.string "address"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id", unique: true
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.string "timezone", default: "UTC"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["token"], name: "index_users_on_token"
  end

  add_foreign_key "alert_subscriptions", "alerts"
  add_foreign_key "alert_subscriptions", "users"
  add_foreign_key "user_login_log", "users"
  add_foreign_key "user_profiles", "users"
end
