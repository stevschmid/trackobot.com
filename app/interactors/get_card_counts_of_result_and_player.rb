class GetCardCountsOfResultAndPlayer
  include Interactor

  def call
    context.card_counts = card_counts
  end

  private

  def card_counts
    @card_counts ||= Hash.new(0).tap do |card_counts|
      context.result.card_history_list.each do |card_history|
        next unless count_card_history? card_history
        card_counts[card_history[:card_id]] += 1
      end
    end
  end

  def count_card_history?(card_history)
    return false if card_history[:player] != context.player

    card = CARDS[card_history[:card_id]]
    return false if card.nil?
    return false if card.type == 'hero'
    return false if card.name == 'The Coin'
    return false if card[:hero] != 'neutral' && context.player == 'me' && card[:hero] != result.hero
    return false if card[:hero] != 'neutral' && context.player == 'opponent' && card[:hero] != result.opponent

    true
  end
end
