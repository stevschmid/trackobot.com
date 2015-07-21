class ResultSerializer < ActiveModel::Serializer
  attributes :id, :mode, :hero, :hero_deck, :opponent, :opponent_deck, :coin, :result, :arena_id, :duration, :rank, :legend
  attribute :created_at, key: :added

  has_many :card_histories, key: :card_history

  def card_histories
    object.card_histories.order(:id)
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
