class Stats::ArenaController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    if params[:hero].present?
      @hero = Hero.where('LOWER(name) = ?', params[:hero]).first
    end

    arenas = user_arenas
    arenas = arenas.where('arenas.hero_id = ?', @hero.id) if @hero

    results = Result.where(arena: arenas)

    num_wins_per_arena = arenas
      .joins("LEFT JOIN results ON results.arena_id = arenas.id AND results.win = #{ActiveRecord::Base::connection.quote(true)}")
      .group('arenas.id', 'arenas.hero_id')
      .count('results.id')

    count_by_wins = Array.new(13, 0)

    # count it up!
    num_wins_per_arena.each do |(_, hero_id), num_wins|
      count_by_wins[num_wins] += 1
    end

    @stats = {
      overall: {
        wins: results.arena.wins.count,
        losses: results.arena.losses.count,
        total: results.count,
        runs: arenas.count
      },
      count_by_wins: count_by_wins
    }

    respond_to do |format|
      format.html
      format.json do
        render json: {stats: @stats}
      end
    end
  end

end
