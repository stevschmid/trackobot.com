class ResultsController < ApplicationController
  respond_to :json, :html

  include ApiDenier
  before_filter :deny_api_calls!, except: %i[create update]

  after_filter :verify_authorized
  after_filter :verify_policy_scoped

  def create
    @result = policy_scope(Result).new(safe_params)
    authorize @result

    if card_history = params[:result][:card_history]
      add_card_history_to_result(@result, card_history)
    end

    case
    when @result.arena?
      AssignArenaToResult.call(result: @result)
    else
      AssignDecksToResult.call(result: @result)
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

    respond_with(:profile, @result.reload)
  end

  def destroy
    @result = policy_scope(Result).find(params[:id])
    authorize @result
    @result.destroy
    if @result.arena && @result.arena.results.count == 0
      @result.arena.destroy
    end
    respond_with(:profile, @result)
  end

  private

  def exclude_result_from_learning?(result)
    last_updated_result = result.user.results
                            .where('created_at != updated_at')
                            .order(:updated_at)
                            .last
    last_updated_result && last_updated_result.updated_at > 1.hour.ago && !current_user.admin?
  end

  def add_card_history_to_result(result, card_history)
    result.build_card_history(data: card_history)
  end

  def safe_params
    params.require(:result).permit(:mode, :win, :hero, :opponent,
                                   :coin, :duration, :rank, :legend,
                                   :deck_id, :opponent_deck_id,
                                   :note, :added)
  end

end
