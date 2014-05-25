class CreateCardHistories < ActiveRecord::Migration
  def change
    create_table :card_histories do |t|
      t.references :card, index: true
      t.references :result, index: true
      t.string :player

      t.timestamps
    end
  end
end
