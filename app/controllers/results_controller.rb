class ResultsController < ApplicationController
  respond_to :json, :html

  include ApiDenier
  before_filter :deny_api_calls!, except: %i[create]

  after_filter :verify_authorized
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
    @result = policy_scope(Result).find(params[:id])
    authorize @result

    # Now update
    @result.assign_attributes(safe_params)

    if @result.valid? && !@result.arena?
      unless exclude_result_from_learning?(@result)
        if @result.deck_id_changed?
          ClassifyDeckForResult.new(@result).learn_deck_for_player! @result.deck
        end

        if @result.opponent_deck_id_changed?
          ClassifyDeckForResult.new(@result).learn_deck_for_opponent! @result.opponent_deck
        end
      end
    end

    @result.save

    if params[:result].has_key?(:tags)
      @result.tags.destroy_all
      tags = (params[:result][:tags] || '').split(',')
      tags.each do |tag|
        @result.tags.create!(tag: tag)
      end
    end

    respond_with(:profile, @result.reload)
  end

  def destroy
    @result = policy_scope(Result).find(params[:id])
    authorize @result
    @result.destroy
    respond_with(:profile, @result)
  end

  private

  def exclude_result_from_learning?(result)
    last_updated_result = result.user.results
                            .where('created_at != updated_at')
                            .order(:updated_at)
                            .last
    last_updated_result && last_updated_result.updated_at > 1.hour.ago
  end

  def add_card_history_to_result(result, card_history)
    result.card_history_list = card_history.collect do |card_history_item|
      card = Card.find_by_ref(card_history_item[:card_id])
      if card
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

end
