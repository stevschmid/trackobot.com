class ResultSerializer < ActiveModel::Serializer
  attributes :id, :mode, :hero, :hero_deck, :opponent, :opponent_deck,
    :coin, :result, :arena_id, :duration, :rank, :legend, :note, :added, :card_history

  def card_history
    object.card_history_list.collect do |it|
      it.merge(card: CARDS[it[:card_id]].to_h)
    end
  end

  def hero
    object.hero.name
  end

  def hero_deck
    object.deck ? object.deck.name : nil
  end

  def opponent
    object.opponent.name
  end

  def opponent_deck
    object.opponent_deck ? object.opponent_deck.name : nil
  end

  def include_arena_id?
    object.arena?
  end

  def include_rank?
    object.ranked?
  end

  def include_legend?
    object.ranked?
  end
end
