class AssignDecksToResult
  include Interactor

  def call
    result = context.result
    context.fail! if result.arena?

    classify = ClassifyDeckForResult.new(result)
    result.deck ||= classify.predict_deck_for_player
    result.opponent_deck ||= classify.predict_deck_for_opponent
  end
end
