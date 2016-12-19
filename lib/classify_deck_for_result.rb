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
    ClassifyDeckForHero.new(result.hero, count_by_cards_for('me'))
  end

  def classify_deck_for_opponent
    ClassifyDeckForHero.new(result.opponent, count_by_cards_for('opponent'))
  end

  def count_by_cards_for player
    card_histories = result.card_history_list.select do |it|
      it[:player] == player
    end.reject do |it|
      skip_card?(it[:card_id], player)
    end

    Hash[card_histories.group_by { |it| it[:card_id] }.collect do |card_id, items|
      [card_id, items.count]
    end]
  end

  def skip_card?(card_id, player)
    card = CARDS[card_id]
    return true if card.nil?
    return true if card.type == 'hero' # ignore hero powers
    return true if card.name == 'The Coin' # ignore coin
    return true if (card_hero = hero_from_card(card)) && player == 'me' && card_hero != result.hero
    return true if (card_hero = hero_from_card(card)) && player == 'opponent' && card_hero != result.opponent
    false
  end

  def hero_from_card(card)
    @heroes ||= Hero.all.index_by { |hero| hero.name.downcase }
    @heroes[card.hero]
  end
end
