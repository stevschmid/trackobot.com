class AddUserIdToResults < ActiveRecord::Migration
  def change
    add_column :results, :user_id, :integer
  end
end
