class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :kind
      t.text :message

      t.timestamps
    end
  end
end
