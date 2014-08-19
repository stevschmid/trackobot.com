module Stats
  extend ActiveSupport::Concern

  TIME_RANGE_FILTERS = %w[last_24_hours last_3_days current_month]

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

  def win_rate(wins, losses)
    total = wins + losses
    return 0 if total == 0
    return wins.to_f / total
  end

  def group_results_by(results, group_item_or_items, id_key, filter_by_key, filter_by_value = nil)
    Hash[
      [ group_item_or_items ].flatten.collect do |group_item|
        group_results = results.where(id_key => group_item.id)
        group_results = group_results.where(filter_by_key => filter_by_value) if filter_by_value
        [ group_item, { total: group_results.count, wins: group_results.wins.count, losses: group_results.losses.count } ]
      end.sort_by { |_, stats| [ win_rate(stats[:wins], stats[:losses]), stats[:total] ] }.reverse # sort desc
    ]
  end
end
