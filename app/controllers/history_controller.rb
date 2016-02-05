class HistoryController < ApplicationController
  include Meta

  def index
    @unpaged_results = current_user.results.order('results.created_at DESC')
    @unpaged_results = @unpaged_results.where(mode: Result.modes[params[:mode]]) if params[:mode].present? && Result.modes.has_key?(params[:mode])
    if params[:arena_id].present?
      @arena = current_user.arenas.find(params[:arena_id])
      @unpaged_results = @unpaged_results.where(arena_id: @arena.id)
    end

    @query = params.fetch(:query, '').strip.downcase
    if @query.present?
      if Result.modes.keys.include?(@query)
        @unpaged_results = @unpaged_results.where(mode: Result.modes[@query])
      else
        deck_ids = current_user.decks.where('name ILIKE ?', "%#{@query}%").map(&:id)
        hero_ids = Hero.where('name ILIKE ?', "%#{@query}%").map(&:id)
        @unpaged_results = @unpaged_results.where('deck_id IN (?) OR opponent_deck_id IN (?) OR hero_id IN (?) OR opponent_id IN (?)', deck_ids, deck_ids, hero_ids, hero_ids)
      end
    end

    @results = @unpaged_results.page(params[:page])
    @results.includes!(:hero)
            .includes!(:opponent)
            .includes!(:tags)

    @decks = current_user.decks

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

  def timeline
    @result = current_user.results.find(params[:id])
    @card_histories = @result.card_history_list
    render layout: false
  end

  def card_stats
    result = current_user.results.find(params[:id])
    player = params[:player].to_sym
    @card_histories = result.card_history_list.select { |entry| entry.player == player }
    render layout: false
  end

end
