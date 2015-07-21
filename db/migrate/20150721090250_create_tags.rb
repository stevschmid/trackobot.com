class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.references :result, index: true
      t.string :tag, index: true, null: false

      t.timestamps
    end
  end
end
