class Deck < ActiveRecord::Base
  belongs_to :hero
  belongs_to :user

  validates_presence_of :name

  has_and_belongs_to_many :cards

  after_save :update_results

  def update_results
    eligible_results = user.results.where.not(mode: Result.modes[:arena])

    # reset old results which this associated deck
    eligible_results.where(deck_id: id).update_all(deck_id: nil)
    eligible_results.where(opponent_deck_id: id).update_all(opponent_deck_id: nil)

    # find new results
    deck_results = eligible_results.joins(:card_histories)
      .where('card_histories.card_id' => cards.pluck(:id))

    user_decks = deck_results.where('card_histories.player' => 'me', hero: hero)
    user_decks.update_all(deck_id: id)

    opponent_decks = deck_results.where('card_histories.player' => 'opponent', opponent: hero)
    opponent_decks.update_all(opponent_deck_id: id)
  end
end
