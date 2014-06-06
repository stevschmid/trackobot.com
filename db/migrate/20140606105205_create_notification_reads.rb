class CreateNotificationReads < ActiveRecord::Migration
  def change
    create_table :notification_reads do |t|
      t.references :notification, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
