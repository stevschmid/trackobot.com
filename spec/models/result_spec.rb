require 'spec_helper'

describe Result do

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

  describe 'card history list' do
    let(:first_play) { FactoryGirl.build(:card_history_entry, player: :me) }
    let(:second_play) { FactoryGirl.build(:card_history_entry, player: :opponent) }

    let(:result) { FactoryGirl.create(:result, mode: :ranked, card_history_list: [first_play, second_play]) }

    it 'has card_history_list in the right order' do
      expect(result.card_history_list.collect(&:player)).to eq [:me, :opponent]
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

    let(:shaman_cards) { Card.all.select { |card| card.hero == 'shaman' } }

    def build_result(as, vs, opts)
      FactoryGirl.build(:result, mode: mode, hero: Hero.find_by_name(as), opponent: Hero.find_by_name(vs), user: user).tap do |result|
        list = []
        opts.each_pair do |player, card_names|
          cards = Card.where(name: card_names).group_by(&:name)
          card_names.inject(1) do |turn, card_name|
            list << CardHistoryEntry.new(turn: turn, player: player, card: cards[card_name].first)
            turn + 1
          end
        end

        result.card_history_list = list
      end
    end

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

    it 'bla' do
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

        result = build_result 'Shaman', 'Warrior', me: card_list,  opponent: []
        result.save!

        [true_deck, result]
      end

      learn_results.each do |true_deck, result|
        ClassifyDeckForResult.new(result).learn_deck_for_player! true_deck
      end

      accuracy = NUM_VALIDATION_RUNS.times.collect do
        true_deck, card_list = build_card_list(shaman_prob_matrix, shaman_cards)
        result = build_result 'Shaman', 'Warrior', me: card_list,  opponent: []
        result.save!
        result.deck == true_deck ? 1 : 0
      end.sum / NUM_VALIDATION_RUNS.to_f

      expect(accuracy).to be >= 0.9
    end

  end

end
