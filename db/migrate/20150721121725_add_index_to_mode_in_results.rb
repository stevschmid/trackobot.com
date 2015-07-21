class AddIndexToModeInResults < ActiveRecord::Migration
  def change
    add_index :results, :mode
  end
end
