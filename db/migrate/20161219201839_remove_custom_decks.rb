class RemoveCustomDecks < ActiveRecord::Migration
  def change
    drop_table :custom_decks
    drop_table :cards_custom_decks

    remove_column :results, :custom_deck_id
    remove_column :results, :opponent_custom_deck_id
  end
end
