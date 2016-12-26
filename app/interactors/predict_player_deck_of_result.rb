class PredictPlayerDeckOfResult
  include Interactor
  include DeckClassification

  MIN_CARDS_FOR_PREDICTION = 5

  def call
    return if num_cards < MIN_CARDS_FOR_PREDICTION
    best_deck, best_score = scores_by_deck.max_by { |_, score| score }
    if best_score >= 1.0 # are we somewhat certain?
      context.deck = best_deck
      context.score = best_score
    end
  end

  private

  def scores_by_deck
    @scores_by_deck ||= eligible_decks.collect { |deck| [deck, deck.classifier.predict_score(normalized_card_counts)] }.to_h
  end
end
