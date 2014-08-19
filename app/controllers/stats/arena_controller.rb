class Stats::ArenaController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    if params[:hero].present?
      @hero = Hero.where('LOWER(name) = ?', params[:hero]).first
    end

    num_wins_per_arena = user_arenas
      .joins("LEFT JOIN results ON results.arena_id = arenas.id AND results.win = #{ActiveRecord::Base::connection.quote(true)}")
      .group('arenas.id', 'arenas.hero_id')
      .count('results.id')

    count_by_wins = Array.new(13, 0)

    # count it up!
    num_wins_per_arena.each do |(_, hero_id), num_wins|
      next if @hero and hero_id != @hero.id
      count_by_wins[num_wins] += 1
    end

    @stats = {
      overall: {
        wins: user_results.arena.wins.count,
        losses: user_results.arena.losses.count,
        total: user_results.count,
        runs: user_arenas.count
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
