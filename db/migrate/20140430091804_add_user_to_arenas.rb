class AddUserToArenas < ActiveRecord::Migration
  def change
    add_reference :arenas, :user, index: true
  end
end
