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
      decks: {
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

    if params[:as_deck].present?
      @as_deck = current_user.decks.where('LOWER(name) = ?', params[:as_deck]).first
    end
    if params[:vs_deck].present?
      @vs_deck = current_user.decks.where('LOWER(name) = ?', params[:vs_deck]).first
    end

    user_results = current_user.results
    user_results = user_results.where('created_at >= ?', min_date_for_time_range(@time_range)) if @time_range
    user_results = user_results.where(mode: Result.modes[@mode]) if @mode

    user_arenas = current_user.arenas
    user_arenas = user_arenas.where('arenas.created_at >= ?', min_date_for_time_range(@time_range)) if @time_range

    @stats[:classes][:as] = group_results_by(user_results, Hero.all, @as_hero, :hero_id, :opponent_id, @vs_hero.try(:id))
    @stats[:classes][:vs] = group_results_by(user_results, Hero.all, @vs_hero, :opponent_id, :hero_id, @as_hero.try(:id))

    @stats[:decks][:as] = group_results_by(user_results, current_user.decks, @as_deck, :deck_id, :opponent_deck_id, @vs_deck.try(:id))
    @stats[:decks][:vs] = group_results_by(user_results, current_user.decks, @vs_deck, :opponent_deck_id, :deck_id, @as_deck.try(:id))

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

  def group_results_by(results, all_group_elements, group_element, group_id_key, filter_key, filter_value = nil)
    Hash[
      [ group_element || all_group_elements ].flatten.collect do |group|
        group_results = results.where(group_id_key => group.id)
        if filter_value
          group_results = group_results.where(filter_key => filter_value)
        end
        [ group, { total: group_results.count, wins: group_results.wins.count, losses: group_results.losses.count } ]
      end.sort_by { |_, stats| [ win_rate(stats[:wins], stats[:losses]), stats[:total] ] }.reverse # sort desc
    ]
  end
end
