class ResultSerializer < ActiveModel::Serializer
  attributes :id, :mode, :hero, :opponent, :coin, :result, :arena_id
  attribute :created_at, key: :added

  has_many :card_histories, key: :card_history

  def hero
    object.hero.name
  end

  def opponent
    object.opponent.name
  end

  def include_arena_id?
    object.arena?
  end
end
