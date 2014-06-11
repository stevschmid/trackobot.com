class CardHistorySerializer < ActiveModel::Serializer
  attributes :player
  has_one :card
end
