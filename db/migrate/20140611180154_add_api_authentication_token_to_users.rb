class AddApiAuthenticationTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_authentication_token, :string
    # generate tokens
    User.all.map(&:save)
  end
end
