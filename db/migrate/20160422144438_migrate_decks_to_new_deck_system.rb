class MigrateDecksToNewDeckSystem < ActiveRecord::Migration
  def change
    # rename the old decks for backup purposes
    rename_table :decks, :custom_decks

    rename_column :cards_decks, :deck_id, :custom_deck_id
    rename_table :cards_decks, :cards_custom_decks

    rename_column :results, :deck_id, :custom_deck_id
    rename_column :results, :opponent_deck_id, :opponent_custom_deck_id

    # create new (global) table
    create_table :decks do |t|
      t.string :name
      t.references :hero
      t.text :classifier

      t.datetime
    end

    change_table :results do |t|
      t.references :deck, index: true
      t.references :opponent_deck, index: true
    end
  end
end
