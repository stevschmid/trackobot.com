class AddMissingIndices < ActiveRecord::Migration
  def change
    add_index :results, :win
    add_index :cards, :ref
  end
end
