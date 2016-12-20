require 'spec_helper'

describe Result do

  include ResultHelper

  describe 'deck assignment' do
    # this is some kind of elaborate integration test
    # for the whole deck system
    let(:user) { FactoryGirl.create(:user) }
    let(:mode) { :ranked }

    let(:shaman) { Hero.find_by_name('Shaman') }

    let(:midrange_shaman) { Deck.find_by!(key: 'midrange', hero: shaman) }
    let(:aggro_shaman) { Deck.find_by!(key: 'aggro', hero: shaman) }

    let(:shaman_cards) { CARDS.values.select { |card| card.hero == 'shaman' } }

    def build_card_list(prob_matrix, deck, cards)
      probs = prob_matrix[deck]

      # avg 12, stddev 5
      card_list = rand(7..17).times.collect do
        roll = rand
        chosen = nil
        probs.inject(0.0) do |sum, (name, prob)|
          chosen ||= name if roll <= sum + prob
          sum + prob
        end
        chosen
      end.compact

      card_list
    end

    it 'does the ring at the right time for the right reasons' do
      NUM_LEARN_RUNS = 10
      NUM_VALIDATION_RUNS = 10

      shaman_prob_matrix = {
        midrange_shaman => {
          'Totem Golem' => 0.7,
          'Doomhammer' => 0.2,
          'Lava Burst' => 0.1,
        },
        aggro_shaman => {
          'Totem Golem' => 0.1,
          'Doomhammer' => 0.4,
          'Lava Burst' => 0.5,
        }
      }

      NUM_LEARN_RUNS.times do
        shaman_prob_matrix.each_key do |true_deck|
          card_list = build_card_list(shaman_prob_matrix, true_deck, shaman_cards)
          result = build_result_with_history 'Shaman', 'Warrior', mode, user, me: card_list,  opponent: []
          ClassifyDeckForResult.new(result).learn_deck_for_player! true_deck
        end
      end

      num_correct = 0
      num_total = 0

      NUM_VALIDATION_RUNS.times do
        shaman_prob_matrix.each_key do |true_deck|
          card_list = build_card_list(shaman_prob_matrix, true_deck, shaman_cards)
          result = build_result_with_history 'Shaman', 'Warrior', mode, user, me: card_list,  opponent: []
          AssignDecksToResult.call(result: result)
          num_correct += (result.deck == true_deck ? 1 : 0)
          if result.deck != true_deck
            Rails.logger.info "[Classify] #{result.deck ? result.deck.full_name : 'NOT_PREDICTED'} #{true_deck.full_name} #{card_list}"
          end
          num_total += 1
        end
      end
      accuracy = num_correct.to_f / num_total
      expect(accuracy).to be >= 0.9
    end

  end

end
