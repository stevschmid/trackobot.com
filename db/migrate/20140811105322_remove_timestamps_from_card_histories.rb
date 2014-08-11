class RemoveTimestampsFromCardHistories < ActiveRecord::Migration
  def change
    remove_column :card_histories, :created_at, :string
    remove_column :card_histories, :updated_at, :string
  end
end
