class AddOneTimeAuthenticationTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :one_time_authentication_token, :string
  end
end
