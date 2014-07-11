class Card < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  has_and_belongs_to_many :decks

  scope :playable, -> do
    # select cards which were recorded as played
    where('EXISTS(SELECT card_histories.id FROM card_histories WHERE card_histories.card_id = cards.id LIMIT 1)')
    .where.not(ref: [ # remove duplicated cards
      'EX1_165t1', # druid of the claw minion
      'EX1_165t2' , # druid of the claw minion
      'CS2_mirror', # mirror image minion
      'ds1_whelptoken', # whelp
      'EX1_116t', # whelp
      'TU4c_006', # bananas
      'TU4c_006e', # bananas
      'EX1_158t', # treant
      'EX1_573t', # treant
      'EX1_tk9', # treant
      'NEW1_040t', # gnoll
      'TU4a_003', # gnoll
      'tt_010a', # spellbender minion
    ])
  end
end
