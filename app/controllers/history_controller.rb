class HistoryController < ApplicationController
  include Meta

  def index
    @unpaged_results = current_user.results.order('results.created_at DESC')
    @unpaged_results = @unpaged_results.where(mode: Result.modes[params[:mode]]) if params[:mode].present? && Result.modes.has_key?(params[:mode])
    if params[:arena_id].present?
      @arena = current_user.arenas.find(params[:arena_id])
      @unpaged_results = @unpaged_results.where(arena_id: @arena.id)
    end
    @results = @unpaged_results.page(params[:page])
    @results.includes!(:card_histories => :card)
            .includes!(:player_card_histories => :card)
            .includes!(:opponent_card_histories => :card)
            .includes!(:hero)
            .includes!(:opponent)

    respond_to do |format|
      format.html
      format.json do
        render json: @results, meta: meta(@results)
      end
      format.csv do
        render text: @unpaged_results.to_csv
      end
    end
  end

end
