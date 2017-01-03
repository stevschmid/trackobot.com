class DropUnusedIndices < ActiveRecord::Migration[5.0]
  def change
    remove_index :results, name: 'index_results_on_deck_id'
    remove_index :results, name: 'index_results_on_opponent_deck_id'

    remove_index :results, name: 'index_results_on_hero'
    remove_index :results, name: 'index_results_on_opponent'

    remove_index :results, name: 'index_results_on_win'
    remove_index :results, name: 'index_results_on_mode'
  end
end
