class CreateResultDeckMatchViews < ActiveRecord::Migration
  def up
    if respond_to?(:create_view)
      create_view :match_decks_with_results, %{
        SELECT results.id AS result_id,
               results.user_id,
               cards_decks.deck_id,
               card_histories.player,
               COUNT(card_histories.id) AS cards_matched
        FROM results
          JOIN decks ON decks.user_id = results.user_id
          JOIN cards_decks ON cards_decks.deck_id = decks.id
          JOIN card_histories ON card_histories.result_id = results.id
            AND card_histories.card_id = cards_decks.card_id
            AND ((card_histories.player = 0 AND decks.hero_id = results.hero_id) OR (card_histories.player = 1 AND decks.hero_id = results.opponent_id))
        GROUP BY results.id,
                 results.user_id,
                 cards_decks.deck_id,
                 card_histories.player
        HAVING count(card_histories.id) > 0
      }

      create_view :match_best_decks_with_results, %q{
        SELECT s.result_id,
               s.user_id,
               s.deck_id,
               s.player,
               s.cards_matched
        FROM match_decks_with_results s
        JOIN (
            SELECT result_id, user_id, player, MAX(cards_matched) AS max_cards_matched FROM match_decks_with_results GROUP BY result_id, user_id, player
        ) m ON s.result_id = m.result_id AND s.cards_matched = m.max_cards_matched AND s.user_id = m.user_id AND s.player = m.player
      }
    end
  end

  def down
    if respond_to?(:drop_view)
      drop_view :match_best_decks_with_results
      drop_view :match_decks_with_results
    end
  end
end
