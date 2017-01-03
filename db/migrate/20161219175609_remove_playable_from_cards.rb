class RemovePlayableFromCards < ActiveRecord::Migration
  def change
    remove_index :cards, name: 'index_cards_on_playable'
    remove_column :cards, :playable
  end
end
