class Stats::ClassesController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    if params[:as_hero].present?
      @as_hero = Hero.where('LOWER(name) = ?', params[:as_hero]).first
    end
    if params[:vs_hero].present?
      @vs_hero = Hero.where('LOWER(name) = ?', params[:vs_hero]).first
    end

    @stats = {
      overall: {
        wins: user_results.wins.count,
        losses: user_results.losses.count,
        total: user_results.count
      },
      as_class: group_results_by(user_results, @as_hero || Hero.all, :hero_id, :opponent_id, @vs_hero.try(:id)),
      vs_class: group_results_by(user_results, @vs_hero || Hero.all, :opponent_id, :hero_id, @as_hero.try(:id))
    }

    respond_to do |format|
      format.html
      format.json do
        render json: {stats: @stats}
      end
    end
  end

end
