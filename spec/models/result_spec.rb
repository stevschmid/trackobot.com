require 'spec_helper'

describe Result do

  include ResultHelper

  describe 'arena result' do
    let(:result) { FactoryGirl.create(:result, mode: :arena) }
    let(:arena) { result.arena }

    context 'result is the last remaining result of arena' do
      it 'deletes the arena' do
        expect { result.destroy }.to change { arena.destroyed? }
      end
    end

    context 'result is one among many results of arena' do
      before do
        2.times { FactoryGirl.create(:result, arena: arena) }
      end

      it 'does not delete the arena' do
        expect { result.destroy }.to_not change { arena.destroyed? }
      end
    end
  end

  describe 'deck assignment' do
    # this is some kind of elaborate integration test
    # for the whole deck system
    let(:user) { FactoryGirl.create(:user) }
    let(:mode) { :ranked }

    let(:shaman) { Hero.find_by_name('Shaman') }

    let(:midrange_shaman) { Deck.find_by!(key: 'midrange', hero: shaman) }
    let(:aggro_shaman) { Deck.find_by!(key: 'aggro', hero: shaman) }

    let(:shaman_cards) { CARDS.values.select { |card| card.hero == 'shaman' } }

    def build_card_list(prob_matrix, cards)
      deck = prob_matrix.keys.sample
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

      [deck, card_list]
    end

    it 'does the ring at the right time for the right reasons' do
      NUM_LEARN_RUNS = 20
      NUM_VALIDATION_RUNS = 10

      shaman_prob_matrix = {
        midrange_shaman => {
          'Totem Golem' => 0.9,
          'Lava Burst' => 0.1,
        },
        aggro_shaman => {
          'Totem Golem' => 0.1,
          'Lava Burst' => 0.9,
        }
      }

      learn_results = NUM_LEARN_RUNS.times.collect do
        true_deck, card_list = build_card_list(shaman_prob_matrix, shaman_cards)

        result = build_result_with_history 'Shaman', 'Warrior', mode, user, me: card_list,  opponent: []
        result.save!

        [true_deck, result]
      end

      learn_results.each do |true_deck, result|
        ClassifyDeckForResult.new(result).learn_deck_for_player! true_deck
      end

      accuracy = NUM_VALIDATION_RUNS.times.collect do
        true_deck, card_list = build_card_list(shaman_prob_matrix, shaman_cards)
        result = build_result_with_history 'Shaman', 'Warrior', mode, user, me: card_list,  opponent: []
        result.save!
        result.deck == true_deck ? 1 : 0
      end.sum / NUM_VALIDATION_RUNS.to_f

      expect(accuracy).to be >= 0.9
    end

  end

end
