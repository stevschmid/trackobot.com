class ReduceSizeOfEnumsInResults < ActiveRecord::Migration[5.0]
  def change
     # one byte is enough for enum
    change_column :results, :hero, :integer, limit: 1
    change_column :results, :opponent, :integer, limit: 1
  end
end
