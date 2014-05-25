class CardHistory < ActiveRecord::Base
  default_scope { order(:id) }

  belongs_to :card
  belongs_to :result

  validates_presence_of :card, :result, :player
  validates_inclusion_of :player, in: %w[me opponent]

  scope :me, ->{ where(player: 'me') }
  scope :opponent, ->{ where(player: 'opponent') }
end
