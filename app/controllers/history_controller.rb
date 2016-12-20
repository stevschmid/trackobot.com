class HistoryController < ApplicationController
  include Meta

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped

  def index
    @unpaged_results = policy_scope(Result).order('results.created_at DESC')
    @unpaged_results = @unpaged_results.where(mode: Result.modes[params[:mode]]) if params[:mode].present? && Result.modes.has_key?(params[:mode])
    if params[:arena_id].present?
      @arena = policy_scope(Arena).find(params[:arena_id])
      @unpaged_results = @unpaged_results.where(arena_id: @arena.id)
    end

    @query = params.fetch(:query, '').strip.downcase
    if @query.present?
      if Result.modes.keys.include?(@query)
        @unpaged_results = @unpaged_results.where(mode: Result.modes[@query])
      elsif (decks = Deck.where('name ILIKE ?', "%#{@query}%")) && decks.any?
        @unpaged_results = @unpaged_results.where('deck_id IN (?) OR opponent_deck_id IN (?)', decks.pluck(:id), decks.pluck(:id))
      elsif hero = Hero.where('name ILIKE ?', "%#{@query}%").first
        @unpaged_results = @unpaged_results.where('hero_id = ? OR opponent_id = ?', hero.id, hero.id)
      else
        @unpaged_results = @unpaged_results.where('note LIKE ?', "%#{@query}%")
      end
    end

    @results = @unpaged_results.page(params[:page])
    @results.includes!(:hero)
            .includes!(:opponent)

    @decks = Deck.all

    respond_to do |format|
      format.html
      format.json do
        render json: @results, meta: meta(@results), root: 'history'
      end
      format.csv do
        render body: ExportResultsToCSV.call(results: @unpaged_results).output
      end
    end
  end

  def timeline
    @result = policy_scope(Result).find(params[:id])
    authorize @result, :show?
    @card_histories = @result.card_history_list
    render layout: false
  end

  def card_stats
    result = policy_scope(Result).find(params[:id])
    authorize result, :show?
    player = params[:player]
    @card_histories = result.card_history_list.select do |entry|
      entry[:player] == player
    end
    render layout: false
  end

end
