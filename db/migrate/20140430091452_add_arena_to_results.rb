class AddArenaToResults < ActiveRecord::Migration
  def change
    add_reference :results, :arena, index: true
  end
end
