class Stats::DecksController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    @decks = policy_scope(Deck)
    @heroes = Hero.all

    @decks_by_id = Hash[@decks.collect { |deck| [deck.id, deck] }]
    @heroes_by_id = Hash[@heroes.collect { |hero| [hero.id, hero] }]

    as_deck = collect_stats(:hero_id, :deck_id)
    vs_deck = collect_stats(:opponent_id, :opponent_deck_id)

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
      stat[:hero_id] = deck.hero_id
      stat[:wins]   = grouped.select { |(win, _, deck_id), _| win && deck_id == deck.id }.values.sum
      stat[:losses] = grouped.select { |(win, _, deck_id), _| !win && deck_id == deck.id }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    Hero.all.each do |hero|
      key = "Other #{hero.name.pluralize}"
      stat = (stats[key] ||= {})
      stat[:deck_id] = nil
      stat[:hero_id] = hero.id
      stat[:wins]   = grouped.select { |(win, id, deck_id), _| win && id == hero.id && deck_id == nil }.values.sum
      stat[:losses] = grouped.select { |(win, id, deck_id), _| !win && id == hero.id && deck_id == nil }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    stats
  end

end
