class AddDeckToResults < ActiveRecord::Migration
  def change
    change_table :results do |t|
      t.references :deck, index: true
      t.references :opponent_deck, index: true
    end
  end
end
