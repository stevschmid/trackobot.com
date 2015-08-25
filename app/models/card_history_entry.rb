class CardHistoryEntry
  include ActiveModel::Model

  attr_accessor :player, :card, :turn
end
