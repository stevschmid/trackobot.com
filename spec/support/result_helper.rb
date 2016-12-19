module ResultHelper
  def build_result_with_history(as, vs, mode, user, history)
    @cards_by_name ||= CARDS.values.index_by(&:name)

    FactoryGirl.build(:result, mode: mode, hero: Hero.find_by_name(as), opponent: Hero.find_by_name(vs), user: user).tap do |result|
      data = []

      history.each_pair do |player, card_names|
        card_names.inject(1) do |turn, card_name|
          data << {
            turn: turn,
            player: player,
            card_id: @cards_by_name[card_name].id
          }

          turn + 1
        end
      end

      result.build_card_history(data: data)
    end
  end
end
