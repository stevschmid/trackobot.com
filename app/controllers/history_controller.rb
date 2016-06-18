class HistoryController < ApplicationController
  include Meta

  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped

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
      elsif deck = current_user.decks.where('name ILIKE ?', "%#{@query}%").first
        @unpaged_results = @unpaged_results.where('deck_id = ? OR opponent_deck_id = ?', deck.id, deck.id)
      elsif hero = Hero.where('name ILIKE ?', "%#{@query}%").first
        @unpaged_results = @unpaged_results.where('hero_id = ? OR opponent_id = ?', hero.id, hero.id)
      else
        @unpaged_results = @unpaged_results.where('EXISTS ( SELECT t.tag FROM tags t WHERE t.result_id = results.id AND t.tag = ? )', @query)
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
    @result = policy_scope(Result).find(params[:id])
    authorize @result, :show?
    @card_histories = @result.card_history_list
    render layout: false
  end

  def card_stats
    result = policy_scope(Result).find(params[:id])
    authorize result, :show?
    player = params[:player].to_sym
    @card_histories = result.card_history_list.select { |entry| entry.player == player }
    render layout: false
  end

end
