class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :ref
      t.string :name
      t.string :description
      t.integer :mana
      t.string :type
      t.string :hero
      t.string :set
      t.string :quality
      t.string :race
      t.integer :attack
      t.integer :health

      t.timestamps
    end
  end
end
