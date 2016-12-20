class Stats::ArenaController < ApplicationController
  respond_to :json, :html

  include Stats

  before_action :ensure_arena_mode

  def index
    num_wins_per_arena = user_arenas
      .joins("LEFT JOIN results ON results.arena_id = arenas.id AND results.win = #{ActiveRecord::Base::connection.quote(true)}")
      .group('arenas.id')
      .count('results.id')

    count_by_wins = Array.new(13, 0)
    num_wins_per_arena.each { |_, num_wins| count_by_wins[num_wins] += 1 }

    as_hero = {}
    as = user_results.arena.group(:win, :hero_id).count
    Hero.all.each do |hero|
      stat = (as_hero[hero] ||= {})
      stat[:wins]   = as.select { |(win, hero_id), _| win && hero_id == hero.id }.values.sum
      stat[:losses] = as.select { |(win, hero_id), _| !win && hero_id == hero.id }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    num_runs_per_hero = user_arenas.group('arenas.hero_id').count
    num_runs_per_hero.each { |hero_id, num_runs| as_hero[Hero.find(hero_id)][:runs] = num_runs }

    @stats = {
      overall: {
        wins: user_results.arena.wins.count,
        losses: user_results.arena.losses.count,
        total: user_results.arena.count,
        runs: user_arenas.count
      },
      as_hero: sort_grouped_stats(as_hero),
      count_by_wins: count_by_wins
    }

    respond_to do |format|
      format.html
      format.json do
        render json: {stats: @stats}
      end
    end
  end

  private

  def ensure_arena_mode
    @mode = :arena
  end

end
