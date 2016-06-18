class Stats::DecksController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    as_deck = {}
    as = user_results.group(:win, :deck_id).count
    current_user.decks.each do |deck|
      stat = (as_deck[deck] ||= {})
      stat[:wins]   = as.select { |(win, deck_id), _| win && deck_id == deck.id }.values.sum
      stat[:losses] = as.select { |(win, deck_id), _| !win && deck_id == deck.id }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    vs_deck = {}
    vs = user_results.group(:win, :opponent_deck_id).count
    current_user.decks.each do |deck|
      stat = (vs_deck[deck] ||= {})
      stat[:wins]   = vs.select { |(win, opponent_deck_id), _| win && opponent_deck_id == deck.id }.values.sum
      stat[:losses] = vs.select { |(win, opponent_deck_id), _| !win && opponent_deck_id == deck.id }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    @stats = {
      overall: {
        wins: user_results.wins.count,
        losses: user_results.losses.count,
        total: user_results.count
      },
      as_deck: sort_grouped_stats(as_deck),
      vs_deck: sort_grouped_stats(vs_deck)
    }

    respond_to do |format|
      format.html
      format.json do
        render json: {stats: @stats}
      end
    end
  end

end
