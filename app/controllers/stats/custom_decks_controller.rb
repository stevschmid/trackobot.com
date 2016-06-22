class Stats::CustomDecksController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    @decks = current_user.custom_decks
    @decks_by_id = Hash[@decks.collect { |deck| [deck.id, deck] }]

    as_deck = collect_stats(:custom_deck_id)
    vs_deck = collect_stats(:opponent_custom_deck_id)

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

  private

  def collect_stats(key_deck_id)
    stats = {}

    grouped = user_results.group(:win, key_deck_id).count
    @decks.each do |deck|
      key = deck.full_name
      stat = (stats[key] ||= {})
      stat[:deck_id] = deck.id
      stat[:hero_id] = deck.hero_id
      stat[:wins]   = grouped.select { |(win, deck_id), _| win && deck_id == deck.id }.values.sum
      stat[:losses] = grouped.select { |(win, deck_id), _| !win && deck_id == deck.id }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    stats
  end

end
