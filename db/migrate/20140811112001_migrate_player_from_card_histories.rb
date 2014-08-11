class MigratePlayerFromCardHistories < ActiveRecord::Migration
  def change
    remove_column :card_histories, :player
    rename_column :card_histories, :player_enum, :player
  end
end
