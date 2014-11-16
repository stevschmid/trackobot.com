class AddRankInfoToResults < ActiveRecord::Migration
  def change
    add_column :results, :rank, :integer
    add_column :results, :legend, :integer
  end
end
