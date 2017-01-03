# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170103140314) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arenas", force: :cascade do |t|
    t.integer  "hero"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.index ["hero"], name: "index_arenas_on_hero", using: :btree
    t.index ["user_id"], name: "index_arenas_on_user_id", using: :btree
  end

  create_table "card_histories", force: :cascade do |t|
    t.integer  "result_id"
    t.jsonb    "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["result_id"], name: "index_card_histories_on_result_id", using: :btree
  end

  create_table "cards", force: :cascade do |t|
    t.string   "ref"
    t.string   "name"
    t.string   "description"
    t.integer  "mana"
    t.string   "type"
    t.string   "hero"
    t.string   "set"
    t.string   "quality"
    t.string   "race"
    t.integer  "attack"
    t.integer  "health"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ref"], name: "index_cards_on_ref", using: :btree
  end

  create_table "decks", force: :cascade do |t|
    t.string   "name"
    t.integer  "hero"
    t.text     "classifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key"
    t.datetime "last_decay_at"
    t.index ["hero"], name: "index_decks_on_hero", using: :btree
    t.index ["key", "hero"], name: "index_decks_on_key_and_hero", unique: true, using: :btree
  end

  create_table "heros", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notification_reads", force: :cascade do |t|
    t.integer  "notification_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["notification_id"], name: "index_notification_reads_on_notification_id", using: :btree
    t.index ["user_id"], name: "index_notification_reads_on_user_id", using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "kind"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",     default: false
  end

  create_table "results", force: :cascade do |t|
    t.integer  "mode"
    t.boolean  "coin"
    t.boolean  "win"
    t.integer  "hero",
    t.integer  "opponent",
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "arena_id"
    t.integer  "duration"
    t.integer  "rank"
    t.integer  "legend"
    t.integer  "deck_id"
    t.integer  "opponent_deck_id"
    t.string   "note"
    t.index ["arena_id"], name: "index_results_on_arena_id", using: :btree
    t.index ["user_id"], name: "index_results_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                         default: "",    null: false
    t.string   "encrypted_password",            default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "one_time_authentication_token"
    t.string   "username",                                      null: false
    t.string   "sign_up_ip"
    t.string   "api_authentication_token"
    t.string   "displayname"
    t.boolean  "deck_tracking",                 default: true
    t.boolean  "admin",                         default: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "card_histories", "results"
end
