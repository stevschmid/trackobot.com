class Result < ApplicationRecord
  enum mode: [:ranked, :casual, :practice, :arena, :friendly]

  enum hero: Hero::MAPPING, _suffix: true
  enum opponent: Hero::MAPPING, _suffix: true

  belongs_to :deck, optional: true
  belongs_to :opponent_deck, class_name: 'Deck', optional: true

  belongs_to :user
  belongs_to :arena, optional: true

  has_one :card_history, dependent: :destroy

  scope :wins, ->{ where(win: true) }
  scope :losses, ->{ where(win: false) }

  validates_presence_of :mode, :hero, :opponent, :user
  validates_inclusion_of :win, in: [true, false]

  validates_absence_of :deck_id, if: :arena?
  validates_absence_of :opponent_deck_id, if: :arena?

  validate :decks_belong_to_rightful_class

  def decks_belong_to_rightful_class
    errors.add(:deck_id, 'is invalid') if deck && deck.hero != self.hero
    errors.add(:opponent_deck_id, 'is invalid') if opponent_deck && opponent_deck.hero != self.opponent
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

  def result
    win? ? 'win' : 'loss'
  end
end
