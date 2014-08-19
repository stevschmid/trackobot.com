class Stats::ArenaController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    num_wins_per_arena = user_arenas
      .joins("LEFT JOIN results ON results.arena_id = arenas.id AND results.win = #{ActiveRecord::Base::connection.quote(true)}")
      .group('arenas.id', 'arenas.hero_id')
      .count('results.id')

    wins_per_run_and_hero  = {}
    num_wins_per_arena.each do |(_, hero_id), num_wins|
      run = (wins_per_run_and_hero[num_wins] ||= {})
      run[hero_id] ||= 0
      run[hero_id] += 1
    end

    @stats = Hash[wins_per_run_and_hero.collect do |(wins, count_per_hero)|
      # map hero_id to name
      [
        wins,
        Hash[count_per_hero.collect { |(hero_id, count)| [Hero.find(hero_id).name, count] }.sort_by { |_, count| count }.reverse ]
      ]
    end.sort]

    respond_to do |format|
      format.html
      format.json do
        render json: {stats: @stats}
      end
    end
  end

end
