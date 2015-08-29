# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150829131553) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arenas", force: :cascade do |t|
    t.integer  "hero_id",    index: {name: "index_arenas_on_hero_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    index: {name: "index_arenas_on_user_id"}
  end

  create_table "card_history_data", force: :cascade do |t|
    t.json    "data"
    t.integer "result_id", index: {name: "index_card_history_data_on_result_id"}
  end

  create_table "cards", force: :cascade do |t|
    t.string   "ref",         limit: 255, index: {name: "index_cards_on_ref"}
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.integer  "mana"
    t.string   "type",        limit: 255
    t.string   "hero",        limit: 255
    t.string   "set",         limit: 255
    t.string   "quality",     limit: 255
    t.string   "race",        limit: 255
    t.integer  "attack"
    t.integer  "health"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "playable",    default: false, index: {name: "index_cards_on_playable"}
  end

  create_table "cards_decks", id: false, force: :cascade do |t|
    t.integer "card_id"
    t.integer "deck_id"
  end

  create_table "decks", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "hero_id",    index: {name: "index_decks_on_hero_id"}
    t.integer  "user_id",    index: {name: "index_decks_on_user_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "user_id",    index: {name: "index_feedbacks_on_user_id"}
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "heros", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notification_reads", force: :cascade do |t|
    t.integer  "notification_id", index: {name: "index_notification_reads_on_notification_id"}
    t.integer  "user_id",         index: {name: "index_notification_reads_on_user_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "kind",       limit: 255
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",     default: false
  end

  create_table "results", force: :cascade do |t|
    t.integer  "mode",              index: {name: "index_results_on_mode"}
    t.boolean  "coin"
    t.boolean  "win",               index: {name: "index_results_on_win"}
    t.integer  "hero_id",           index: {name: "index_results_on_hero_id"}
    t.integer  "opponent_id",       index: {name: "index_results_on_opponent_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",           index: {name: "index_results_on_user_id"}
    t.integer  "arena_id",          index: {name: "index_results_on_arena_id"}
    t.integer  "deck_id",           index: {name: "index_results_on_deck_id"}
    t.integer  "opponent_deck_id",  index: {name: "index_results_on_opponent_deck_id"}
    t.integer  "duration"
    t.integer  "rank"
    t.integer  "legend"
    t.binary   "card_history_data"
  end

  create_table "tags", force: :cascade do |t|
    t.integer  "result_id",  index: {name: "index_tags_on_result_id"}
    t.string   "tag",        null: false, index: {name: "index_tags_on_tag"}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                         limit: 255, default: "", null: false
    t.string   "encrypted_password",            limit: 255, default: "", null: false
    t.string   "reset_password_token",          limit: 255, index: {name: "index_users_on_reset_password_token", unique: true}
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",            limit: 255
    t.string   "last_sign_in_ip",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "one_time_authentication_token", limit: 255
    t.string   "username",                      limit: 255,              null: false
    t.string   "sign_up_ip",                    limit: 255
    t.string   "api_authentication_token",      limit: 255
    t.string   "displayname",                   limit: 255
  end

end
