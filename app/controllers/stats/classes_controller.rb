class Stats::ClassesController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    as_class = {}
    as = user_results.group(:win, :hero).count
    Hero::MAPPING.each_value do |h|
      stat = (as_class[h] ||= {})
      stat[:wins]   = as.select { |(win, hero), _| win && hero == h }.values.sum
      stat[:losses] = as.select { |(win, hero), _| !win && hero == h }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    vs_class = {}
    vs = user_results.group(:win, :opponent).count
    Hero::MAPPING.each_value do |h|
      stat = (vs_class[h] ||= {})
      stat[:wins]   = vs.select { |(win, opponent), _| win && opponent == h }.values.sum
      stat[:losses] = vs.select { |(win, opponent), _| !win && opponent == h }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    @stats = {
      overall: {
        wins: user_results.wins.count,
        losses: user_results.losses.count,
        total: user_results.count
      },
      as_class: sort_grouped_stats(as_class),
      vs_class: sort_grouped_stats(vs_class)
    }

    respond_to do |format|
      format.html
      format.json do
        render json: {stats: @stats}
      end
    end
  end

end
