class ExportResultsToCSV
  include Interactor

  def call
    context.output = CSV.generate do |csv|
      csv << [:id, :mode, :hero, :hero_deck, :opponent, :opponent_deck, :result, :coin, :arena_id, :duration, :rank, :legend, :added]

      context.results.find_each do |result|
        csv << [
          result.id,
          result.mode,
          result.hero.titleize,
          result.deck ? result.deck.name : nil,
          result.opponent.titleize,
          result.opponent_deck ? result.opponent_deck.name : nil,
          result.result,
          result.coin,
          result.arena && result.arena.id,
          result.duration,
          result.rank,
          result.legend,
          result.created_at
        ]
      end
    end
  end
end
