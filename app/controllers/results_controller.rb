class ResultsController < ApplicationController
  respond_to :json, :html

  def create
    @result = current_user.results.new(safe_params)
    if card_history = params[:result][:card_history]
      add_card_history_for_result(@result, card_history)
    end
    @result.save
    respond_with(:profile, @result)
  end

  private

  def add_card_history_for_result(result, card_history)
    card_history.each do |card_history_item|
      card = Card.find_by_ref(card_history_item[:card_id])
      if card
        result.card_histories.new(turn: card_history_item[:turn], player: card_history_item[:player], card: card)
      else
        logger.info "Card #{card_history_item[:card_id]} not found in Card Database"
      end
    end
  end

  def safe_params
    fix_params(params.require(:result).permit(:mode, :win, :hero, :opponent, :coin, :duration, :rank, :legend))
  end

  def fix_params(params)
    # ToB <= 0.2.1 delivers the wrong coin information
    fix_necessary = false

    if request.user_agent.index("Mozilla") # old version without explicit User-Agent
      fix_necessary = true
    elsif request.user_agent =~ /Track-o-Bot\/(\d+\.\d+\.\d+)/
      version = Gem::Version.new($1)
      if version <= Gem::Version.new('0.2.1')
        fix_necessary = true
      end
    end

    if fix_necessary
      params[:coin] = !params[:coin]
    end

    params
  end

end
