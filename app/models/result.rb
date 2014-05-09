class Result < ActiveRecord::Base
  paginates_per 15

  enum mode: [:ranked, :casual, :practice, :arena]

  belongs_to :hero
  belongs_to :opponent, class_name: 'Hero'

  belongs_to :user

  belongs_to :arena

  scope :wins, ->{ where(win: true) }
  scope :losses, ->{ where(win: false) }

  before_create :connect_to_arena, if: :arena?

  def hero=(hero)
    if hero.kind_of?(String)
      hero = Hero.where('lower(name) = ?', hero.downcase).first
    end
    super(hero)
  end

  def opponent=(opponent)
    if opponent.kind_of?(String)
      opponent = Hero.where('lower(name) = ?', opponent.downcase).first
    end
    super(opponent)
  end

  def connect_to_arena
    current_arena = user.arenas.order('created_at').last
    if current_arena &&
      current_arena.hero == hero &&
      current_arena.wins.count < 12 &&
      current_arena.losses.count < 3
    then
      self.arena = current_arena
    end

    self.arena ||= user.arenas.create(hero: hero)
  end

  def result
    case win
    when true
      'win'
    when false
      'loss'
    else
      nil
    end
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << [:id, :mode, :hero, :opponent, :result, :coin, :arena_id, :added]

      all.each do |result|
        csv << [
          result.id,
          result.mode,
          result.hero.name,
          result.opponent.name,
          result.result,
          result.coin,
          result.arena && result.arena.id,
          result.created_at
        ]
      end
    end
  end
end
