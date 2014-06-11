class StatsController < ApplicationController
  respond_to :json, :html

  def index

    @stats = {
      overall: {
      },
      classes: {
        vs: {},
        as: {}
      },
      arena: {
        runs: {}
      }
    }

    Hero.all.each do |hero|
      as_results = current_user.results.where(hero_id: hero.id)
      vs_results = current_user.results.where(opponent_id: hero.id)
      @stats[:classes][:as][hero.name] = { wins: as_results.wins.count, losses: as_results.losses.count }
      @stats[:classes][:vs][hero.name] = { wins: vs_results.wins.count, losses: vs_results.losses.count }
    end

    num_wins_per_arena = current_user.arenas
      .joins("LEFT JOIN results ON results.arena_id = arenas.id AND results.win = #{ActiveRecord::Base::connection.quote(true)}")
      .group('arenas.id')
      .count('results.id')

    num_wins_per_arena.each do |_, num_wins|
      @stats[:arena][:runs][num_wins] ||= 0
      @stats[:arena][:runs][num_wins] += 1
    end

    @stats[:overall][:wins] = current_user.results.wins.count
    @stats[:overall][:losses] = current_user.results.losses.count

    respond_to do |format|
      format.html
      format.json do
        render json: {stats: @stats}
      end
    end
  end
end
