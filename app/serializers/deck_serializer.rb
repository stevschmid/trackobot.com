class DeckSerializer < ActiveModel::Serializer
  attributes :id, :name, :hero
  attribute :created_at, key: :added

  def hero
    object.hero ? object.hero.titleize : nil
  end
end
