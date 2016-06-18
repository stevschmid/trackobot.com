class MigratePlayerFromCardHistories < ActiveRecord::Migration
  def change
    if defined? CardHistory
      CardHistory.where(player_enum: nil).where(player: 'me').update_all(player_enum: 0)
      CardHistory.where(player_enum: nil).where(player: 'opponent').update_all(player_enum: 1)
      remove_column :card_histories, :player
      rename_column :card_histories, :player_enum, :player
    end
  end
end
