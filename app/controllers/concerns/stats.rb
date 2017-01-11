module Stats
  extend ActiveSupport::Concern

  PARAMS = %i[
    query
    mode
    as_hero
    vs_hero
    as_deck
    vs_deck
    time_range
    order
    start
    end
    sort_by
  ]

  TIME_RANGE_FILTERS = %w[last_24_hours last_3_days current_month custom]

  SORT_BY_FIELDS = %w[winrate share]
  DEFAULT_SORT_BY = :winrate

  ORDER_FIELDS = %w[asc desc]
  DEFAULT_ORDER = :desc

  included do
    before_action :read_params

    after_action :verify_policy_scoped
  end

  def user_results
    @results ||= begin
                   results = policy_scope(Result)
                   if @time_range
                     results = results.where('created_at >= ? AND created_at <= ?', @time_range_start, @time_range_end)
                   end
                   results = results.where(mode: Result.modes[@mode]) if @mode

                   results = results.where(hero: @as_hero) if @as_hero
                   results = results.where(opponent: @vs_hero) if @vs_hero

                   results = results.where(deck_id: @as_deck.id) if @as_deck
                   results = results.where(opponent_deck_id: @vs_deck.id) if @vs_deck
                   results
                 end
  end

  def user_arenas
    @user_arenas ||= begin
                       user_arenas = policy_scope(Arena)
                       if @time_range
                         user_arenas = user_arenas.where('arenas.created_at >= ? AND arenas.created_at <= ?', @time_range_start, @time_range_end)
                       end
                       user_arenas = user_arenas.where('arenas.hero = ?', Hero::MAPPING.key(@as_hero)) if @as_hero
                       user_arenas = user_arenas.where('arenas.opponent = ?', Hero::MAPPING.key(@vs_hero)) if @vs_hero
                       user_arenas
                     end
  end

  def read_params
    cookies.delete(:mode) if stats_params[:mode] == 'all'
    if stats_params[:mode].present? && Result.modes.has_key?(params[:mode].to_sym)
      @mode = stats_params[:mode].to_sym
      cookies.permanent[:mode] = @mode
    end
    @mode ||= cookies[:mode]

    cookies.delete(:time_range) if stats_params[:time_range] == 'all'
    time_range = stats_params[:time_range] || cookies[:time_range]
    if time_range.present? && TIME_RANGE_FILTERS.include?(time_range)
      @time_range = time_range.to_sym
      cookies.permanent[:time_range] = @time_range

      if @time_range == :custom
        custom_start = stats_params[:start] || cookies[:custom_start] || Date.today.to_s
        custom_end = stats_params[:end] || cookies[:custom_end] || Date.today.to_s
        cookies.permanent[:custom_start] = custom_start
        cookies.permanent[:custom_end] = custom_end
        @custom_range = Date.parse(custom_start)..Date.parse(custom_end)
      end


      @time_range_start = min_date_for_time_range.beginning_of_day
      @time_range_end = max_date_for_time_range.end_of_day
    end

    @sort_by ||= DEFAULT_SORT_BY
    if stats_params[:sort_by].present? && SORT_BY_FIELDS.include?(params[:sort_by])
      @sort_by = stats_params[:sort_by].to_sym
    end

    @order ||= DEFAULT_ORDER
    if stats_params[:order].present? && ORDER_FIELDS.include?(params[:order])
      @order = stats_params[:order].to_sym
    end

    if stats_params[:as_deck].present?
      @as_deck = Deck.find_by_id(stats_params[:as_deck])
    end

    if stats_params[:vs_deck].present?
      @vs_deck = Deck.find_by_id(stats_params[:vs_deck])
    end

    if Hero::LIST.include?(stats_params[:as_hero])
      @as_hero = stats_params[:as_hero]
    end

    if Hero::LIST.include?(stats_params[:vs_hero])
      @vs_hero = stats_params[:vs_hero]
    end
  end

  def min_date_for_time_range
    case @time_range
    when :last_24_hours
      24.hours.ago
    when :last_3_days
      3.days.ago
    when :current_month
      Date.today.beginning_of_month
    when :custom
      @custom_range.min
    else
      Date.today
    end
  end

  def max_date_for_time_range
    case @time_range
    when :custom
      @custom_range.max
    else
      Date.tomorrow
    end
  end

  def winrate(wins, losses)
    total = wins + losses
    return 0 if total == 0
    return wins.to_f / total
  end

  def sort_grouped_stats(grouped_stats)
    sorted = grouped_stats.sort_by do |group, stats|
      case @sort_by
      when :share
        stats[:total]
      else
        [winrate(stats[:wins], stats[:losses]), stats[:total]]
      end
    end
    sorted = sorted.reverse if @order == :desc
    Hash[sorted]
  end

  def stats_params
    params.permit(*PARAMS)
  end
end
