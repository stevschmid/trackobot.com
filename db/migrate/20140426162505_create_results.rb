class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.integer :mode
      t.boolean :coin
      t.boolean :win
      t.references :hero, index: true
      t.references :opponent, index: true

      t.timestamps
    end
  end
end
