class ClassifyDeckForResult
  attr_reader :result

  def initialize(result)
    @result = result
  end

  def predict_deck_for_player
    classify_deck_for_player.predict
  end

  def learn_deck_for_player! true_deck
    classify_deck_for_player.learn! true_deck
  end

  def predict_deck_for_opponent
    classify_deck_for_opponent.predict
  end

  def learn_deck_for_opponent! true_deck
    classify_deck_for_opponent.learn! true_deck
  end

  private

  def classify_deck_for_player
    ClassifyDeckForHero.new(result.hero, count_by_cards_for(:me))
  end

  def classify_deck_for_opponent
    ClassifyDeckForHero.new(result.opponent, count_by_cards_for(:opponent))
  end

  def count_by_cards_for player
    card_histories = result.card_history_list.select do |card_history_entry|
      card_history_entry.player == player # only from specified player
    end.reject do |card_history_entry|
      card_history_entry.card.type == 'hero' # ignore hero powers
    end

    Hash[card_histories.group_by(&:card).collect do |card, items|
      [card.ref, items.count]
    end]
  end

end
