class ReplaceResultDeckMatchViewsWithQuotient < ActiveRecord::Migration
  def up
    drop_view :match_best_decks_with_results
    drop_view :match_decks_with_results
    create_view :match_decks_with_results, %{
      SELECT results.id AS result_id,
             results.user_id,
             cards_decks.deck_id,
             card_histories.player,
             COUNT(card_histories.id) AS cards_count_match,
             (SELECT COUNT(deck_id) FROM cards_decks AS inner_cards_decks WHERE inner_cards_decks.deck_id = cards_decks.deck_id) AS cards_count_deck,
             (SELECT COUNT(result_id) FROM card_histories WHERE card_histories.result_id = results.id) AS cards_count_result
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
    create_view :match_decks_with_results_quotient, %{
      SELECT result_id,
             user_id,
             deck_id,
             player,
             cards_count_match * 10000 / LEAST(cards_count_deck, cards_count_result) + cards_count_deck AS cards_quotient
	  FROM match_decks_with_results 
	}
    create_view :match_best_decks_with_results, %q{
      SELECT s.result_id,
             s.user_id,
             s.deck_id,
             s.player,
             s.cards_quotient
      FROM match_decks_with_results_quotient s
      JOIN (
          SELECT result_id, user_id, player, MAX(cards_quotient) AS max_cards_quotient FROM match_decks_with_results_quotient GROUP BY result_id, user_id, player
      ) m ON s.result_id = m.result_id AND s.cards_quotient = m.max_cards_quotient AND s.user_id = m.user_id AND s.player = m.player
    }
  end

  def down
    drop_view :match_best_decks_with_results
    drop_view :match_decks_with_results_quotient
    drop_view :match_decks_with_results
	create_view :match_decks_with_results, %{
      SELECT results.id AS result_id,
             results.user_id,
             cards_decks.deck_id,
             card_histories.player,
             count(card_histories.id) AS cards_matched
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
