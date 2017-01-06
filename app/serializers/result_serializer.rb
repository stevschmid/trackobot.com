class ResultSerializer < ActiveModel::Serializer
  attributes :id, :mode, :hero, :hero_deck, :opponent, :opponent_deck,
    :coin, :result, :duration, :note, :added, :card_history

  attribute :arena_id, if: -> (r) { r.object.arena? }
  attribute :rank, if: -> (r) { r.object.ranked? }
  attribute :legend, if: -> (r) { r.object.ranked? }

  def card_history
    object.card_history_list.collect do |it|
      card = CARDS[it[:card_id]]
      next if card.nil?
      it.except(:card_id).merge(card: { id: card.id, name: card.name, mana: card.mana })
    end.compact
  end

  def hero
    object.hero.titleize
  end

  def hero_deck
    object.deck.try(:name)
  end

  def opponent
    object.opponent.titleize
  end

  def opponent_deck
    object.opponent_deck.try(:name)
  end
end
