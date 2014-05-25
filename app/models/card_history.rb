class CardHistory < ActiveRecord::Base
  belongs_to :card
  belongs_to :result

  validates_presence_of :card, :result, :player
  validates_inclusion_of :player, in: %w[me opponent]
end
