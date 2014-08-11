class MakePlayerEnumForCardHistories < ActiveRecord::Migration
  def change
    add_column :card_histories, :player_enum, :integer

    CardHistory.reset_column_information
    CardHistory.where(player: 'me').update_all(player_enum: 0)
    CardHistory.where(player: 'opponent').update_all(player_enum: 1)
  end
end
