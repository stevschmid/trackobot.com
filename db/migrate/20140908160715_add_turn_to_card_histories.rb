class AddTurnToCardHistories < ActiveRecord::Migration
  def change
    add_column :card_histories, :turn, :integer
  end
end
