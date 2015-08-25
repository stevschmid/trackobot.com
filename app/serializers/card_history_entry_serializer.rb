class CardHistoryEntrySerializer < ActiveModel::Serializer
  attributes :player, :turn
  has_one :card
end
