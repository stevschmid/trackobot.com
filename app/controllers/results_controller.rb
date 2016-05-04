class ResultsController < ApplicationController
  respond_to :json, :html

  before_filter :deny_api_calls!, except: %i[create]

  def create
    @result = current_user.results.new(safe_params)
    if card_history = params[:result][:card_history]
      add_card_history_to_result(@result, card_history)
    end
    @result.save
    respond_with(:profile, @result.reload)
  end

  def update
    @result = current_user.results.find(params[:id])
    @result.update_attributes(safe_params)
    respond_with(:profile, @result.reload)
  end

  def set_tags
    @result = current_user.results.find(params[:id])
    @result.tags.destroy_all
    tags = params[:tags].present? ? params[:tags].split(',') : []
    tags.each { |tag| @result.tags.create!(tag: tag) }
    render nothing: true
  end

  def bulk_delete
    current_user.results.where(id: params[:result_ids]).destroy_all if params[:result_ids]
    redirect_to profile_history_index_path, flash: { success: 'Selected result(s) deleted.' }
  end

  def bulk_update
    selected_results = current_user.results
      .where(id: params[:result_ids])
      .where.not(mode: Result.modes[:arena]) # arena results are not eligible for update

    if as_deck = Deck.find_by_id(params[:as_deck])
      selected_results
        .where(hero: as_deck.hero)
        .update_all(deck_id: as_deck.id)
    end

    if vs_deck = Deck.find_by_id(params[:vs_deck])
      selected_results
        .where(opponent: vs_deck.hero)
        .update_all(opponent_deck_id: vs_deck.id)
    end

    redirect_to profile_history_index_path, flash: { success: 'Selected result(s) updated.' }
  end

  private

  def add_card_history_to_result(result, card_history)
    result.card_history_list = card_history.collect do |card_history_item|
      card = Card.find_by_ref(card_history_item[:card_id])
      if card
        # HS cards are heavily redundant
        # To make sure we can distinguish between playable
        # non-playable cards, mark them here the first time
        # are played
        card.mark_as_playable!

        CardHistoryEntry.new(turn: card_history_item[:turn],
                             player: card_history_item[:player].to_sym,
                             card: card)
      else
        logger.info "Card #{card_history_item[:card_id]} not found in Card Database"
        nil
      end
    end.compact
  end

  def safe_params
    params.require(:result).permit(:mode, :win, :hero, :opponent, :coin, :duration, :rank, :legend, :added, :deck_id, :opponent_deck_id)
  end

  def deny_api_calls!
    head :unauthorized if params[:token].present?
  end

end
