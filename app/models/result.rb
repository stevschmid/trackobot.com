class Result < ActiveRecord::Base
  paginates_per 15

  validates_presence_of :mode, :hero_id, :opponent_id, :user_id
  validates_inclusion_of :win, in: [true, false]

  enum mode: [:ranked, :casual, :practice, :arena, :friendly]

  belongs_to :hero
  belongs_to :opponent, class_name: 'Hero'

  belongs_to :deck
  belongs_to :opponent_deck, class_name: 'Deck'

  belongs_to :user
  belongs_to :arena

  has_many :card_histories, -> { order(:id) }

  # explicit assocations we can eager load
  has_many :player_card_histories, -> { where(player: CardHistory.players[:me]).order(:id) }, class_name: 'CardHistory'
  has_many :opponent_card_histories, -> { where(player: CardHistory.players[:opponent]).order(:id) }, class_name: 'CardHistory'

  scope :wins, ->{ where(win: true) }
  scope :losses, ->{ where(win: false) }

  before_create :connect_to_arena, if: :arena?
  before_create :connect_to_decks, unless: :arena?

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

  def connect_to_decks
    user.decks.where(hero_id: [hero.id, opponent.id]).each do |deck|
      deck_card_ids = deck.cards.pluck(:id)

      if deck.hero == hero
        hero_card_ids = card_histories.select(&:me?).collect(&:card_id)
        self.deck ||= deck if (hero_card_ids & deck_card_ids).any?
      end

      if deck.hero == opponent
        opponent_card_ids = card_histories.select(&:opponent?).collect(&:card_id)
        self.opponent_deck ||= deck if (opponent_card_ids & deck_card_ids).any?
      end
    end
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
