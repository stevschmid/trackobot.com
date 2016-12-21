class ChangeHeroFieldToEnum < ActiveRecord::Migration[5.0]
  def change
    rename_column :results, :hero_id, :hero
    rename_column :results, :opponent_id, :opponent

    rename_column :decks, :hero_id, :hero
    rename_column :arenas, :hero_id, :hero
  end
end
