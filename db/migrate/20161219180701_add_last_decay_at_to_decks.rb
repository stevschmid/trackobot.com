class AddLastDecayAtToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :last_decay_at, :datetime
  end
end
