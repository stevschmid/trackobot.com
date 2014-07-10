class StatsController < ApplicationController
  respond_to :json, :html

  TIME_RANGE_FILTERS = %w[last_24_hours last_3_days current_month]

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

    if params[:mode].present? && Result.modes.has_key?(params[:mode].to_sym)
      @mode = params[:mode].to_sym
    end

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
    user_results = user_results.where(mode: Result.modes[@mode]) if @mode

    user_arenas = current_user.arenas
    user_arenas = user_arenas.where('arenas.created_at >= ?', min_date_for_time_range(@time_range)) if @time_range

    @stats[:classes][:as] = Hash[
      [@as_hero || Hero.all].flatten.collect do |hero|
        as_results = user_results.where(hero_id: hero.id)
        as_results = as_results.where(opponent_id: @vs_hero.id) if @vs_hero
        [hero.name, {wins: as_results.wins.count, losses: as_results.losses.count}]
      end.sort_by { |_, hero_stats| [win_rate(hero_stats[:wins], hero_stats[:losses]), hero_stats[:wins] + hero_stats[:losses]] }.reverse
    ]

    @stats[:classes][:vs] = Hash[
      [@vs_hero || Hero.all].flatten.collect do |hero|
        vs_results = user_results.where(opponent_id: hero.id)
        vs_results = vs_results.where(hero_id: @as_hero.id) if @as_hero
        [hero.name, {wins: vs_results.wins.count, losses: vs_results.losses.count}]
      end.sort_by { |_, hero_stats| [win_rate(hero_stats[:wins], hero_stats[:losses]), hero_stats[:wins] + hero_stats[:losses]] }.reverse
    ]

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

    @stats[:arena] = Hash[wins_per_run_and_hero.collect do |(wins, count_per_hero)|
      # map hero_id to name
      [
        wins,
        Hash[count_per_hero.collect { |(hero_id, count)| [Hero.find(hero_id).name, count] }.sort_by { |_, count| count }.reverse ]
      ]
    end.sort]

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
    when :last_24_hours
      24.hours.ago
    when :last_3_days
      3.days.ago
    when :current_month
      Date.today.beginning_of_month
    end
  end

  def win_rate(wins, losses)
    total = wins + losses
    return 0 if total == 0
    return wins.to_f / total
  end
end
