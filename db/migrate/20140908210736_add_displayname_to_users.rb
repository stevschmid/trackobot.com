class AddDisplaynameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :displayname, :string
  end
end
