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

  has_many :tags

  has_many :card_histories, -> { order(:id) }, dependent: :destroy

  # explicit assocations we can eager load
  has_many :player_card_histories, -> { where(player: CardHistory.players[:me]).order(:id) }, class_name: 'CardHistory'
  has_many :opponent_card_histories, -> { where(player: CardHistory.players[:opponent]).order(:id) }, class_name: 'CardHistory'

  scope :wins, ->{ where(win: true) }
  scope :losses, ->{ where(win: false) }

  before_create :create_or_update_associated_arena, if: :arena?
  after_create :connect_to_decks, unless: :arena?

  after_destroy :delete_arena_if_last_remaining_result, if: :arena?

  def best_deck_for_hero(hero_id)
    result_card_ids = card_histories.collect(&:card_id).uniq

    # only consider decks with of the specified class
    matching_decks = user.decks.where(hero_id: hero_id)

    # compute quotient for each deck
    quotient_per_decks = matching_decks.inject({}) do |hash, deck|
      hash[deck] = quotient_for_deck(deck, result_card_ids)
      hash
    end

    # remove decks with no match
    quotient_per_decks.reject! { |_, quotient| quotient <= 0 }

    # find best matching deck
    best_deck, _ = quotient_per_decks.max { |(_, q1), (_, q2)| q1 <=> q2 }
    best_deck
  end

  def quotient_for_deck(deck, card_ids)
    deck_card_ids = deck.cards.collect(&:id).uniq
    matching_cards = deck_card_ids & card_ids

    matching_cards.length.to_f / deck_card_ids.length.to_f
  end

  def determine_best_matching_player_deck
    best_deck_for_hero(hero.id)
  end

  def determine_best_matching_opponent_deck
    best_deck_for_hero(opponent.id)
  end

  def card_history_list
    CardHistoryListCoder.load(self.card_history_data)
  end

  def card_history_list=(card_history_list)
    self.card_history_data = CardHistoryListCoder.dump(card_history_list)
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
    self.save!
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
      csv << [:id, :mode, :hero, :hero_deck, :opponent, :opponent_deck, :result, :coin, :arena_id, :duration, :rank, :legend, :added]

      all.each do |result|
        csv << [
          result.id,
          result.mode,
          result.hero.name,
          result.deck ? result.deck.name : nil,
          result.opponent.name,
          result.opponent_deck ? result.opponent_deck.name : nil,
          result.result,
          result.coin,
          result.arena && result.arena.id,
          result.duration,
          result.rank,
          result.legend,
          result.created_at
        ]
      end
    end
  end

  def delete_arena_if_last_remaining_result
    arena.destroy if arena && arena.results.count == 0
  end
end
