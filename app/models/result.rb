class Result < ActiveRecord::Base
  enum mode: [:ranked, :casual, :practice, :arena, :friendly]

  has_one :card_history

  belongs_to :hero
  belongs_to :opponent, class_name: 'Hero'

  belongs_to :deck
  belongs_to :opponent_deck, class_name: 'Deck'

  belongs_to :user
  belongs_to :arena

  scope :wins, ->{ where(win: true) }
  scope :losses, ->{ where(win: false) }

  validates_presence_of :mode, :hero_id, :opponent_id, :user_id
  validates_inclusion_of :win, in: [true, false]

  validates_absence_of :deck_id, if: :arena?
  validates_absence_of :opponent_deck_id, if: :arena?

  validate :decks_belong_to_rightful_class

  before_create :create_or_update_associated_arena, if: :arena?
  before_create :connect_to_decks, unless: :arena?

  after_destroy :delete_arena_if_last_remaining_result, if: :arena?

  def decks_belong_to_rightful_class
    errors.add(:deck_id, 'is invalid') if deck && deck.hero_id != hero_id
    errors.add(:opponent_deck_id, 'is invalid') if opponent_deck && opponent_deck.hero_id != opponent_id
  end

  def added=(timestamp)
    self.created_at = timestamp
  end

  def added
    self.created_at
  end

  def card_history_list
    @card_history_list ||= (card_history.try(:data) || []).map(&:symbolize_keys)
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
    classify = ClassifyDeckForResult.new(self)
    self.deck ||= classify.predict_deck_for_player
    self.opponent_deck ||= classify.predict_deck_for_opponent
  end

  def result
    win? ? 'win' : 'loss'
  end

  def delete_arena_if_last_remaining_result
    arena.destroy if arena && arena.results.count == 0
  end
end

