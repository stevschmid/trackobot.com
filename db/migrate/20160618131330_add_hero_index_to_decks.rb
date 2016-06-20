class AddHeroIndexToDecks < ActiveRecord::Migration
  def change
    add_index :decks, :hero_id
  end
end
