class AddKeyToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :key, :string
    add_index :decks, [:key, :hero_id], unique: true
  end
end
