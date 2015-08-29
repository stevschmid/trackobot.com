class DropOldCardHistory < ActiveRecord::Migration
  def change
    drop_table :card_histories
  end
end
