class Stats::DecksController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    @decks = policy_scope(Deck)
    @heroes = Hero.all

    @decks_by_id = Hash[@decks.collect { |deck| [deck.id, deck] }]
    @heroes_by_id = Hash[@heroes.collect { |hero| [hero.id, hero] }]

    as_deck = {}
    as = user_results.group(:win, :hero_id, :deck_id).count
    @decks.each do |deck|
      key = "#{deck.name} #{deck.hero.name}"
      stat = (as_deck[key] ||= {})
      stat[:deck_id] = deck.id
      stat[:hero_id] = deck.hero_id
      stat[:wins]   = as.select { |(win, _, deck_id), _| win && deck_id == deck.id }.values.sum
      stat[:losses] = as.select { |(win, _, deck_id), _| !win && deck_id == deck.id }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    Hero.all.each do |hero|
      key = "Other #{hero.name}"
      stat = (as_deck[key] ||= {})
      stat[:deck_id] = nil
      stat[:hero_id] = hero.id
      stat[:wins]   = as.select { |(win, hero_id, deck_id), _| win && hero_id == hero.id && deck_id == nil }.values.sum
      stat[:losses] = as.select { |(win, hero_id, deck_id), _| !win && hero_id == hero.id && deck_id == nil }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    vs_deck = {}
    vs = user_results.group(:win, :opponent_id, :opponent_deck_id).count
    @decks.each do |deck|
      key = "#{deck.name} #{deck.hero.name}"
      stat = (vs_deck[key] ||= {})
      stat[:deck_id] = deck.id
      stat[:hero_id] = deck.hero_id
      stat[:wins]   = vs.select { |(win, _, opponent_deck_id), _| win && opponent_deck_id == deck.id }.values.sum
      stat[:losses] = vs.select { |(win, _, opponent_deck_id), _| !win && opponent_deck_id == deck.id }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    Hero.all.each do |hero|
      key = "Other #{hero.name}"
      stat = (vs_deck[key] ||= {})
      stat[:deck_id] = nil
      stat[:hero_id] = hero.id
      stat[:wins]   = vs.select { |(win, opponent_id, opponent_deck_id), _| win && opponent_id == hero.id && opponent_deck_id == nil }.values.sum
      stat[:losses] = vs.select { |(win, opponent_id, opponent_deck_id), _| !win && opponent_id == hero.id && opponent_deck_id == nil }.values.sum
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
