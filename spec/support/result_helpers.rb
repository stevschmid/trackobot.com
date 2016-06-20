module ResultHelpers
  def build_result_with_history(as, vs, mode, user, history)
    FactoryGirl.build(:result, mode: mode, hero: Hero.find_by_name(as), opponent: Hero.find_by_name(vs), user: user).tap do |result|
      list = []
      history.each_pair do |player, card_names|
        cards = Card.where(name: card_names).group_by(&:name)
        card_names.inject(1) do |turn, card_name|
          list << CardHistoryEntry.new(turn: turn, player: player, card: cards[card_name].first)
          turn + 1
        end
      end

      result.card_history_list = list
    end
  end
end
