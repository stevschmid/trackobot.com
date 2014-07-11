class Card < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  has_and_belongs_to_many :decks

  # select cards which were recorded als played
  scope :playable, -> do
    where('EXISTS(SELECT card_histories.id FROM card_histories WHERE card_histories.card_id = cards.id LIMIT 1)')
  end
end
