class CardHistoryEntry
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :player, :card, :turn

  def attributes
    { player: player, card: card, turn: turn }
  end
end
