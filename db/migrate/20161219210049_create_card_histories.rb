class CreateCardHistories < ActiveRecord::Migration
  def change
    create_table :card_histories do |t|
      t.references :result, index: true, foreign_key: true
      t.jsonb :data

      t.timestamps null: false
    end
  end
end
