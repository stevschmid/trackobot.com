class AddCardHistoryDataToResults < ActiveRecord::Migration
  def change
    add_column :results, :card_history_data, :binary
  end
end
