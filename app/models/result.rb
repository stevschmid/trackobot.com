class Result < ApplicationRecord
  enum mode: [:ranked, :casual, :practice, :arena, :friendly]

  has_one :card_history

  belongs_to :user

  belongs_to :hero
  belongs_to :opponent, class_name: 'Hero'

  belongs_to :deck, optional: true
  belongs_to :opponent_deck, class_name: 'Deck', optional: true

  belongs_to :arena, optional: true

  scope :wins, ->{ where(win: true) }
  scope :losses, ->{ where(win: false) }

  validates_presence_of :mode, :hero_id, :opponent_id, :user_id
  validates_inclusion_of :win, in: [true, false]

  validates_absence_of :deck_id, if: :arena?
  validates_absence_of :opponent_deck_id, if: :arena?

  validate :decks_belong_to_rightful_class

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

  def result
    win? ? 'win' : 'loss'
  end
end
