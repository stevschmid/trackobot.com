class LearnPlayerDeckOfResult
  include Interactor
  include DeckClassification

  MIN_CARDS_FOR_LEARNING = 8

  def call
    true_deck   = context.deck
    return if num_cards < MIN_CARDS_FOR_LEARNING
    fail!(error: "Ineligible deck #{true_deck} ≠ #{hero}") if true_deck && eligible_decks.exclude?(true_deck)

    eligible_decks.each do |deck|
      label = true_deck == deck ? 1 : -1
      before_score = deck.classifier.predict_score(normalized_card_counts)
        deck.classifier.train(normalized_card_counts, label)
      after_score = deck.classifier.predict_score(normalized_card_counts)
      Rails.logger.info "[Classify] Learn classifier_deck: #{deck.full_name} true_deck: #{true_deck ? true_deck.full_name : nil} before_score: #{before_score} after_score: #{after_score} label: #{label}"
      deck.save!
    end
  end
end
