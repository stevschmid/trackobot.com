class ResultsController < ApplicationController
  respond_to :json, :html

  def create
    @result = current_user.results.create(safe_params)
    if card_history = params[:result][:card_history]
      add_card_history_for_result(@result, card_history)
    end
    respond_with(:profile, @result)
  end

  private

  def add_card_history_for_result(result, card_history)
    card_history.each do |card_history_item|
      card = Card.find_by_ref(card_history_item[:card_id])
      if card
        result.card_histories << CardHistory.new(player: card_history_item[:player], card: card)
      else
        Rails.log.info "Card #{card_history_item[:card_id]} not found in Card Database"
      end
    end
  end

  def safe_params
    params.require(:result).permit(:mode, :win, :hero, :opponent, :coin)
  end

end
