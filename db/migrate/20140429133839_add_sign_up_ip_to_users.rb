class AddSignUpIpToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sign_up_ip, :string
  end
end
