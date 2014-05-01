class AddUserToResults < ActiveRecord::Migration
  def change
    add_reference :results, :user, index: true
  end
end
