class AddPlayableToCards < ActiveRecord::Migration
  def change
    add_column :cards, :playable, :boolean, default: false
    add_index :cards, :playable
  end
end
