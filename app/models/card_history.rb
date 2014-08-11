class CardHistory < ActiveRecord::Base
  belongs_to :card
  belongs_to :result

  enum player: [:me, :opponent]

  validates_presence_of :card, :player
end
