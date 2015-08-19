class Deck < ActiveRecord::Base
  belongs_to :hero
  belongs_to :user, touch: true

  validates_presence_of :name

  has_and_belongs_to_many :cards

  after_save :update_results

  def update_results
    eligible_results = user.results.where.not(mode: Result.modes[:arena])
    # reset old results which this associated deck/hero
    eligible_results.where('deck_id = ? OR hero_id = ?', id, hero_id).update_all(deck_id: nil)
    eligible_results.where('opponent_deck_id = ? OR opponent_id = ?', id, hero_id).update_all(opponent_deck_id: nil)

    # find the (new) best matching deck for these results
    player_results_to_update = eligible_results.where('results.deck_id IS NULL')
    user.decks.all.each { |deck| player_results_to_update.match_with_player_deck(deck).update_all(deck_id: deck.id) }

    opponent_results_to_update = eligible_results.where('results.opponent_deck_id IS NULL')
    user.decks.all.each { |deck| opponent_results_to_update.match_with_opponent_deck(deck).update_all(opponent_deck_id: deck.id) }
  end

  def to_s
    name
  end
end
