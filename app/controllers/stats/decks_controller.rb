class Stats::DecksController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    @decks = policy_scope(Deck)
    @heroes = Hero::MAPPING.keys.map(&:to_s)

    @decks_by_id = Hash[@decks.collect { |deck| [deck.id, deck] }]

    as_deck = collect_stats(:hero, :deck_id)
    vs_deck = collect_stats(:opponent, :opponent_deck_id)

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

  def collect_stats(key_id, key_deck_id)
    stats = {}

    grouped = user_results.group(:win, key_id, key_deck_id).count
    @decks.each do |deck|
      key = deck.full_name
      stat = (stats[key] ||= {})
      stat[:deck_id] = deck.id
      stat[:hero] = deck.hero
      stat[:wins]   = grouped.select { |(win, _, deck_id), _| win && deck_id == deck.id }.values.sum
      stat[:losses] = grouped.select { |(win, _, deck_id), _| !win && deck_id == deck.id }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    Hero::MAPPING.keys.map(&:to_s).each do |h|
      key = "Other #{h.pluralize}"
      stat = (stats[key] ||= {})
      stat[:deck_id] = nil
      stat[:hero] = h
      stat[:wins]   = grouped.select { |(win, hero, deck_id), _| win && h == hero && deck_id == nil }.values.sum
      stat[:losses] = grouped.select { |(win, hero, deck_id), _| !win && h == hero && deck_id == nil }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    stats
  end

end
