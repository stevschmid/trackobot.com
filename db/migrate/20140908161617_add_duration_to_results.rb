class AddDurationToResults < ActiveRecord::Migration
  def change
    add_column :results, :duration, :integer
  end
end
