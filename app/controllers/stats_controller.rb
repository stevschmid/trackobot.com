class StatsController < ApplicationController
  respond_to :json, :html

  TIME_RANGE_FILTERS = %w[today last_3_days last_30_days]

  def index
    @stats = {
      overall: {
      },
      classes: {
        vs: {},
        as: {}
      },
      arena: {
      }
    }

    if params[:time_range].present? && TIME_RANGE_FILTERS.include?(params[:time_range])
      @time_range = params[:time_range].to_sym
    end

    if params[:as_hero].present?
      @as_hero = Hero.where('LOWER(name) = ?', params[:as_hero]).first
    end
    if params[:vs_hero].present?
      @vs_hero = Hero.where('LOWER(name) = ?', params[:vs_hero]).first
    end

    user_results = current_user.results
    user_results = user_results.where('created_at >= ?', min_date_for_time_range(@time_range)) if @time_range

    user_arenas = current_user.arenas
    user_arenas = user_arenas.where('arenas.created_at >= ?', min_date_for_time_range(@time_range)) if @time_range

    [@as_hero || Hero.all].flatten.each do |hero|
      as_results = user_results.where(hero_id: hero.id)
      as_results = as_results.where(opponent_id: @vs_hero.id) if @vs_hero
      @stats[:classes][:as][hero.name] = { wins: as_results.wins.count, losses: as_results.losses.count }
    end

    [@vs_hero || Hero.all].flatten.each do |hero|
      vs_results = user_results.where(opponent_id: hero.id)
      vs_results = vs_results.where(hero_id: @as_hero.id) if @as_hero
      @stats[:classes][:vs][hero.name] = { wins: vs_results.wins.count, losses: vs_results.losses.count }
    end

    num_wins_per_arena = user_arenas
      .joins("LEFT JOIN results ON results.arena_id = arenas.id AND results.win = #{ActiveRecord::Base::connection.quote(true)}")
      .group('arenas.id', 'arenas.hero_id')
      .count('results.id')

    num_wins_per_arena.each do |(_, hero_id), num_wins|
      key = num_wins
      run = (@stats[:arena][key] ||= {})
      run[hero_id] ||= 0
      run[hero_id] += 1
    end

    @stats[:arena].each do |(key, count_per_hero)|
      # map hero_id to name
      @stats[:arena][key] = Hash[count_per_hero.collect { |(hero_id, count)| [Hero.find(hero_id).name, count] }]
    end

    @stats[:overall][:wins] = user_results.wins.count
    @stats[:overall][:losses] = user_results.losses.count

    respond_to do |format|
      format.html
      format.json do
        render json: {stats: @stats}
      end
    end
  end

  private

  def min_date_for_time_range(time_range)
    case time_range
    when :today
      Date.today
    when :last_3_days
      3.days.ago
    when :last_30_days
      30.days.ago
    end
  end
end
