class DropFeedbacks < ActiveRecord::Migration
  def up
    drop_table :feedbacks
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
