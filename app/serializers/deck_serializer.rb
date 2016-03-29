class DeckSerializer < ActiveModel::Serializer
  attributes :name, :hero_id, :card_ids

  def hero_id
    object.hero.id
  end

  def card_ids
    object.cards.map(&:id)
  end
end
