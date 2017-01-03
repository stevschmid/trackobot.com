class DropCardHistoryDataFromResults < ActiveRecord::Migration[5.0]
  def change
    remove_column :results, :card_history_data
  end
end
