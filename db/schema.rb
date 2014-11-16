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

ActiveRecord::Schema.define(version: 20141116154730) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arenas", force: true do |t|
    t.integer  "hero_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.index ["hero_id"], :name => "index_arenas_on_hero_id"
    t.index ["user_id"], :name => "index_arenas_on_user_id"
  end

  create_table "card_histories", force: true do |t|
    t.integer "card_id"
    t.integer "result_id"
    t.integer "player"
    t.integer "turn"
    t.index ["card_id"], :name => "index_card_histories_on_card_id"
    t.index ["result_id"], :name => "index_card_histories_on_result_id"
  end

  create_table "cards", force: true do |t|
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
    t.index ["ref"], :name => "index_cards_on_ref"
  end

  create_table "cards_decks", id: false, force: true do |t|
    t.integer "card_id"
    t.integer "deck_id"
  end

  create_table "decks", force: true do |t|
    t.string   "name"
    t.integer  "hero_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["hero_id"], :name => "index_decks_on_hero_id"
    t.index ["user_id"], :name => "index_decks_on_user_id"
  end

  create_table "feedbacks", force: true do |t|
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], :name => "index_feedbacks_on_user_id"
  end

  create_table "heros", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "results", force: true do |t|
    t.integer  "mode"
    t.boolean  "coin"
    t.boolean  "win"
    t.integer  "hero_id"
    t.integer  "opponent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "arena_id"
    t.integer  "deck_id"
    t.integer  "opponent_deck_id"
    t.integer  "duration"
    t.integer  "rank"
    t.integer  "legend"
    t.index ["arena_id"], :name => "index_results_on_arena_id"
    t.index ["deck_id"], :name => "index_results_on_deck_id"
    t.index ["hero_id"], :name => "index_results_on_hero_id"
    t.index ["opponent_deck_id"], :name => "index_results_on_opponent_deck_id"
    t.index ["opponent_id"], :name => "index_results_on_opponent_id"
    t.index ["user_id"], :name => "index_results_on_user_id"
    t.index ["win"], :name => "index_results_on_win"
  end

  create_view "match_decks_with_results", " SELECT results.id AS result_id,\n    results.user_id,\n    cards_decks.deck_id,\n    card_histories.player,\n    count(card_histories.id) AS cards_matched\n   FROM (((results\n   JOIN decks ON ((decks.user_id = results.user_id)))\n   JOIN cards_decks ON ((cards_decks.deck_id = decks.id)))\n   JOIN card_histories ON ((((card_histories.result_id = results.id) AND (card_histories.card_id = cards_decks.card_id)) AND (((card_histories.player = 0) AND (decks.hero_id = results.hero_id)) OR ((card_histories.player = 1) AND (decks.hero_id = results.opponent_id))))))\n  GROUP BY results.id, results.user_id, cards_decks.deck_id, card_histories.player\n HAVING (count(card_histories.id) > 0)", :force => true
  create_view "match_best_decks_with_results", " SELECT s.result_id,\n    s.user_id,\n    s.deck_id,\n    s.player,\n    s.cards_matched\n   FROM (match_decks_with_results s\n   JOIN ( SELECT match_decks_with_results.result_id,\n            match_decks_with_results.user_id,\n            match_decks_with_results.player,\n            max(match_decks_with_results.cards_matched) AS max_cards_matched\n           FROM match_decks_with_results\n          GROUP BY match_decks_with_results.result_id, match_decks_with_results.user_id, match_decks_with_results.player) m ON (((((s.result_id = m.result_id) AND (s.cards_matched = m.max_cards_matched)) AND (s.user_id = m.user_id)) AND (s.player = m.player))))", :force => true
  create_table "notification_reads", force: true do |t|
    t.integer  "notification_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["notification_id"], :name => "index_notification_reads_on_notification_id"
    t.index ["user_id"], :name => "index_notification_reads_on_user_id"
  end

  create_table "notifications", force: true do |t|
    t.string   "kind"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",     default: false
  end

  create_table "users", force: true do |t|
    t.string   "email",                         default: "", null: false
    t.string   "encrypted_password",            default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "one_time_authentication_token"
    t.string   "username",                                   null: false
    t.string   "sign_up_ip"
    t.string   "api_authentication_token"
    t.string   "displayname"
    t.index ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  end

end
