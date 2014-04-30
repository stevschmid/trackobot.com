class CreateArenas < ActiveRecord::Migration
  def change
    create_table :arenas do |t|
      t.references :hero, index: true

      t.timestamps
    end
  end
end
