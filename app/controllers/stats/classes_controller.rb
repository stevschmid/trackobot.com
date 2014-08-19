class Stats::ClassesController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    @stats = {
      overall: {
      },
      classes: {
        vs: {},
        as: {}
      }
    }

    if params[:as_hero].present?
      @as_hero = Hero.where('LOWER(name) = ?', params[:as_hero]).first
    end
    if params[:vs_hero].present?
      @vs_hero = Hero.where('LOWER(name) = ?', params[:vs_hero]).first
    end

    @stats[:classes][:as] = group_results_by(user_results, Hero.all, @as_hero, :hero_id, :opponent_id, @vs_hero.try(:id))
    @stats[:classes][:vs] = group_results_by(user_results, Hero.all, @vs_hero, :opponent_id, :hero_id, @as_hero.try(:id))

    @stats[:overall][:wins] = user_results.wins.count
    @stats[:overall][:losses] = user_results.losses.count

    respond_to do |format|
      format.html
      format.json do
        render json: {stats: @stats}
      end
    end
  end

end
