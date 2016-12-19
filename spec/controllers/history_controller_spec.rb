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
      expect(json[:history].count).to eq 1
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

      context 'arena' do
        let!(:result) { FactoryGirl.create(:result, mode: :arena, user: user) }
        its([:arena_id]) { should eq(result.arena.id) }
      end

      context 'no arena' do
        let!(:result) { FactoryGirl.create(:result, mode: :ranked, user: user) }
        it { should_not include(:arena_id) }
      end

      describe 'note' do
        let!(:result) { FactoryGirl.create(:result, mode: :ranked, user: user, note: 'test') }
        its([:note]) { should eq('test') }
      end

      describe 'decks' do
        let(:hero) { Hero.find_by_name('Rogue') }
        let(:opponent) { Hero.find_by_name('Warrior') }

        let(:deck) { Deck.where(hero: hero).first }
        let(:opponent_deck) { Deck.where(hero: opponent).first }

        let!(:result) { FactoryGirl.create(:result, mode: :ranked, user: user, hero: hero, opponent: opponent, deck: deck, opponent_deck: opponent_deck) }

        its([:opponent_deck]) { should eq(result.opponent_deck.name) }
        its([:hero_deck]) { should eq(result.deck.name) }
      end

      describe 'card history' do
        before do
          result.create_card_history(data: [
            {turn: 3, player: :me, card_id: 'EX1_538'}, # unleash
            {turn: 4, player: :opponent, card_id: 'CS2_032'}, # flamestrike
            {turn: 4, player: :me, card_id: 'CS2_033'} # water elemental
          ])
          get :index, format: :json
        end

        specify { expect(subject[:card_history].count).to eq 3 }

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
