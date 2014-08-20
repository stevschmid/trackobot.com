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

  before_create :create_or_update_associated_arena, if: :arena?
  after_create :connect_to_decks, unless: :arena?

  # scopes to use to mass update results after a deck gets updated
  scope :match_with_deck, ->(deck) { joins('INNER JOIN match_best_decks_with_results rb ON rb.result_id = results.id AND rb.user_id = results.user_id').where('rb.deck_id = ?', deck.id) }
  scope :match_with_player_deck, ->(deck) { match_with_deck(deck).where('rb.player = ?', CardHistory.players[:me]) }
  scope :match_with_opponent_deck, ->(deck) { match_with_deck(deck).where('rb.player = ?', CardHistory.players[:opponent]) }

  def determine_best_matching_player_deck
    Deck.find_by_sql(["SELECT deck_id AS id FROM match_best_decks_with_results WHERE result_id = ? AND player = ?", id, CardHistory.players[:me]]).first
  end

  def determine_best_matching_opponent_deck
    Deck.find_by_sql(["SELECT deck_id AS id FROM match_best_decks_with_results WHERE result_id = ? AND player = ?", id, CardHistory.players[:opponent]]).first
  end

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

  def create_or_update_associated_arena
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
    self.deck ||= determine_best_matching_player_deck
    self.opponent_deck ||= determine_best_matching_opponent_deck
    self.save
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
