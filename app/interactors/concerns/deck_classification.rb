module DeckClassification
  extend ActiveSupport::Concern

  def hero
    context.player == 'opponent' ? context.result.opponent : context.result.hero
  end

  def num_cards
    @num_cards ||= card_counts.values.sum
  end

  def card_counts
    @card_counts ||= Hash.new(0).tap do |card_counts|
      context.result.card_history_list.each do |card_history|
        next unless count_card_history? card_history
        card_counts[card_history[:card_id]] += 1
      end
    end
  end

  def normalized_card_counts
    @normalized_card_counts ||= begin
                                  # a deck consists normally of 30 cards
                                  # if we only see 15, make sure we scale them properly
                                  num_cards = card_counts.values.sum
                                  scaling = 30 / num_cards.to_f
                                  card_counts.map { |k, v| [k, v * scaling] }.to_h
                                end
  end

  def eligible_decks
    @eligible_decks ||= Deck.active.where(hero: hero)
  end

  def count_card_history?(card_history)
    return false if card_history[:player] != context.player

    card = CARDS[card_history[:card_id]]
    return false if card.nil?
    return false if card.type == 'HERO_POWER' || card.type == 'HERO'
    return false if card.name == 'The Coin'
    return false if card[:cardClass] != 'NEUTRAL' && context.player == 'me' && card[:cardClass] != context.result.hero.upcase
    return false if card[:cardClass] != 'NEUTRAL' && context.player == 'opponent' && card[:cardClass] != context.result.opponent.upcase

    true
  end
end
