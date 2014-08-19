class Stats::ClassesController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    @stats = {
      overall: {
        wins: user_results.wins.count,
        losses: user_results.losses.count,
        total: user_results.count
      },
      as_class: {},
      vs_class: {}
    }

    as = user_results.group(:win, :hero_id).count
    Hero.all.each do |hero|
      stat = (@stats[:as_class][hero] ||= {})
      stat[:wins]   = as.select { |(win, hero_id), _| win && hero_id == hero.id }.values.sum
      stat[:losses] = as.select { |(win, hero_id), _| !win && hero_id == hero.id }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    vs = user_results.group(:win, :opponent_id).count
    Hero.all.each do |hero|
      stat = (@stats[:vs_class][hero] ||= {})
      stat[:wins]   = vs.select { |(win, opponent_id), _| win && opponent_id == hero.id }.values.sum
      stat[:losses] = vs.select { |(win, opponent_id), _| !win && opponent_id == hero.id }.values.sum
      stat[:total]  = stat[:wins] + stat[:losses]
    end

    respond_to do |format|
      format.html
      format.json do
        render json: {stats: @stats}
      end
    end
  end

end
