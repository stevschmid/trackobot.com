class ResultSerializer < ActiveModel::Serializer
  attributes :id, :mode, :hero, :opponent, :coin, :result, :arena_id
  attribute :created_at, key: :added

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
