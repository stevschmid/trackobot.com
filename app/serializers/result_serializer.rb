class ResultSerializer < ActiveModel::Serializer
  attributes :id, :mode, :hero, :opponent, :coin, :result, :arena_id, :duration, :rank, :legend
  attribute :created_at, key: :added

  has_many :card_histories, key: :card_history

  def card_histories
    object.card_histories.order(:id)
  end

  def hero
    object.hero.name
  end

  def opponent
    object.opponent.name
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
