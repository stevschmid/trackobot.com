class AddDeckTrackingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deck_tracking, :boolean, default: true
  end
end
