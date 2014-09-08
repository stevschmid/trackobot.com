class CardHistorySerializer < ActiveModel::Serializer
  attributes :player, :turn
  has_one :card
end
