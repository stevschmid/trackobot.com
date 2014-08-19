module Stats
  extend ActiveSupport::Concern

  TIME_RANGE_FILTERS = %w[last_24_hours last_3_days current_month]

  SORT_BY_FIELDS = %w[winrate share]
  DEFAULT_SORT_BY = :winrate

  ORDER_FIELDS = %w[asc desc]
  DEFAULT_ORDER = :desc

  included do
    before_action :read_params
  end

  def user_results
    @results ||= begin
                   results = current_user.results
                   results = results.where('created_at >= ?', min_date_for_time_range(@time_range)) if @time_range
                   results = results.where(mode: Result.modes[@mode]) if @mode
                   results
                 end
  end

  def user_arenas
    @user_arenas ||= begin
                       user_arenas = current_user.arenas
                       user_arenas = user_arenas.where('arenas.created_at >= ?', min_date_for_time_range(@time_range)) if @time_range
                       user_arenas
                     end
  end

  def read_params
    if params[:mode].present? && Result.modes.has_key?(params[:mode].to_sym)
      @mode = params[:mode].to_sym
    end

    if params[:time_range].present? && TIME_RANGE_FILTERS.include?(params[:time_range])
      @time_range = params[:time_range].to_sym
    end

    @sort_by ||= DEFAULT_SORT_BY
    if params[:sort_by].present? && SORT_BY_FIELDS.include?(params[:sort_by])
      @sort_by = params[:sort_by].to_sym
    end

    @order ||= DEFAULT_ORDER
    if params[:order].present? && ORDER_FIELDS.include?(params[:order])
      @order = params[:order].to_sym
    end
  end

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

  def winrate(wins, losses)
    total = wins + losses
    return 0 if total == 0
    return wins.to_f / total
  end

  def group_results_by(results, group_item_or_items, id_key, filter_by_key, filter_by_value = nil)
    Hash[
      sort_grouped_results([group_item_or_items].flatten.collect do |group_item|
        group_results = results.where(id_key => group_item.id)
        group_results = group_results.where(filter_by_key => filter_by_value) if filter_by_value
        [ group_item, { total: group_results.count, wins: group_results.wins.count, losses: group_results.losses.count } ]
      end)
    ]
  end

  def sort_grouped_results(grouped_results)
    sorted = grouped_results.sort_by do |_, stats|
      case @sort_by
      when :share
        stats[:total]
      else
        [winrate(stats[:wins], stats[:losses]), stats[:total]]
      end
    end
    sorted = sorted.reverse if @order == :desc
    sorted
  end
end
