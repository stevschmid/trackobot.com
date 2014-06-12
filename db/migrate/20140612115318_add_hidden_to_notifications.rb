class AddHiddenToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :hidden, :bool, default: false
  end
end
