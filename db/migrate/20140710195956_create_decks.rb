class CreateDecks < ActiveRecord::Migration
  def change
    create_table :decks do |t|
      t.string :name
      t.references :hero, index: true
      t.references :user, index: true

      t.timestamps
    end

    create_table :cards_decks, id: false do |t|
      t.belongs_to :card
      t.belongs_to :deck
    end
  end
end
