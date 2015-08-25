require 'spec_helper'

describe HistoryController do

  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in(user)
  end

  context 'json' do
    let!(:result) { FactoryGirl.create(:result, user: user) }

    before do
      get :index, format: :json
    end

    let(:json) { JSON.parse(response.body, symbolize_names: true) }

    it 'has history' do
      expect(json[:history]).to have(1).item
    end

    it 'has meta pagination information' do
      expect(json[:meta].keys).to include(:current_page, :next_page, :prev_page, :total_pages, :total_items)
    end

    describe 'result structure' do
      let(:json_result) { json[:history].first }
      subject { json_result }

      its([:id]) { should eq(result.id) }
      its([:mode]) { should eq(result.mode) }
      its([:hero]) { should eq(result.hero.name) }
      its([:opponent]) { should eq(result.opponent.name) }
      its([:coin]) { should eq(result.coin) }
      its([:result]) { should eq(result.win ? 'win' : 'loss') }
      its([:added]) { should eq(result.created_at.iso8601(3)) }
      its([:duration]) { should eq(result.duration) }

      context 'arena' do
        let!(:result) { FactoryGirl.create(:result, mode: :arena, user: user) }
        its([:arena_id]) { should eq(result.arena.id) }
      end

      context 'ranked' do
        describe 'rank' do
          let!(:result) { FactoryGirl.create(:result, mode: :ranked, user: user, rank: 25) }
          its([:rank]) { should eq(result.rank) }
        end
        describe 'legend' do
          let!(:result) { FactoryGirl.create(:result, mode: :ranked, user: user, legend: 101) }
          its([:legend]) { should eq(result.legend) }
        end
      end

      context 'no arena' do
        let!(:result) { FactoryGirl.create(:result, mode: :ranked, user: user) }
        it { should_not include(:arena_id) }
      end

      context 'decks' do
        let(:deck) { FactoryGirl.create(:deck) }
        let(:opponent_deck) { FactoryGirl.create(:deck) }

        let!(:result) { FactoryGirl.create(:result, mode: :ranked, user: user, deck: deck, opponent_deck: opponent_deck) }

        its([:opponent_deck]) { should eq(result.opponent_deck.name) }
        its([:hero_deck]) { should eq(result.deck.name) }
      end

      describe 'card history' do
        before do
          list = [
            # unleash
            CardHistoryEntry.new(turn: 3, player: :me, card: Card.find_by_ref('EX1_538')),
            # flamestrike
            CardHistoryEntry.new(turn: 4, player: :opponent, card: Card.find_by_ref('CS2_032')),
            # water elemental
            CardHistoryEntry.new(turn: 4, player: :me, card: Card.find_by_ref('CS2_033'))
          ]
          result.update_attributes(card_history_list: list)

          get :index, format: :json
        end

        its([:card_history]) { should have(3).items }

        describe 'card_history structure' do
          let(:json_card_history) { json_result[:card_history] }
          subject { json_card_history.first }

          its([:player]) { should eq 'me' }
          its([:turn]) { should eq 3 }

          describe 'card structure' do
            subject { json_card_history.first[:card] }

            its([:name]) { should eq 'Unleash the Hounds' }
            its([:id]) { should eq 'EX1_538' }
            its([:mana]) { should eq 3 }
          end

        end
      end

    end
  end

end
