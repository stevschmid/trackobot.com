class AssignDecksToResult
  include Interactor

  def call
    result = context.result
    context.fail! if result.arena?

    result.deck ||= predict_deck_of_player
    result.opponent_deck ||= predict_deck_of_opponent
  end

  private

  def predict_deck_of_player
    PredictPlayerDeckOfResult.call(result: context.result, player: 'me').deck
  end

  def predict_deck_of_opponent
    PredictPlayerDeckOfResult.call(result: context.result, player: 'opponent').deck
  end
end
