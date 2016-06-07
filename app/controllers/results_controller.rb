class ResultsController < ApplicationController
  respond_to :json, :html

  before_filter :deny_api_calls!, except: %i[create]

  after_filter :verify_authorized, except: %i[bulk_delete bulk_update]
  after_filter :verify_policy_scoped

  def create
    @result = policy_scope(Result).new(safe_params)
    authorize @result
    if card_history = params[:result][:card_history]
      add_card_history_to_result(@result, card_history)
    end
    @result.save
    respond_with(:profile, @result.reload)
  end

  def update
    @result = current_user.results.find(params[:id])
    authorize @result

    # Learn label provided by user
    if safe_params[:deck_id].present?
      deck = Deck.find_by_id(safe_params[:deck_id])
      ClassifyDeckForResult.new(@result).learn_deck_for_player! deck
    end

    if safe_params[:opponent_deck_id].present?
      opponent_deck = Deck.find_by_id(safe_params[:opponent_deck_id])
      ClassifyDeckForResult.new(@result).learn_deck_for_opponent! opponent_deck
    end

    # Now update
    @result.update_attributes(safe_params)

    if params[:result].has_key?(:tags)
      @result.tags.destroy_all
      tags = (params[:result][:tags] || '').split(',')
      tags.each do |tag|
        @result.tags.create!(tag: tag)
      end
    end

    respond_with(:profile, @result.reload)
  end

  def bulk_delete
    policy_scope(Result).where(id: (params[:result_ids] || [])).destroy_all
    redirect_to profile_history_index_path, flash: { success: 'Selected result(s) deleted.' }
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
