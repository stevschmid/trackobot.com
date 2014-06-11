class CardSerializer < ActiveModel::Serializer
  attribute :ref, key: :id
  attributes :name, :mana
end
