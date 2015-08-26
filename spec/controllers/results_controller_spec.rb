require 'spec_helper'

describe ResultsController do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in(user)
  end

  let(:result_params) do
    {
      hero: 'Shaman',
      opponent: 'Warrior',
      mode: 'ranked',
      coin: true,
      win: true
    }
  end

  let(:card_history) do
    [
      {card_id: 'EX1_405', player: 'opponent'},
      {card_id: 'GAME_005', player: 'me', turn: 3}
    ]
  end

  it 'creates a result' do
    post :create, result: result_params, format: :json
    result = user.results.last

    expect(result.hero.name).to eq('Shaman')
    expect(result.opponent.name).to eq('Warrior')
    expect(result.mode).to eq 'ranked'
    expect(result.coin).to eq true
    expect(result.win).to eq true
  end

  context 'with duration information' do
    it 'creates a result' do
      result_params.merge!(duration: 42)
      post :create, result: result_params, format: :json
      result = user.results.last
      expect(result.duration).to eq 42
    end
  end

  context 'with rank information' do
    let(:chicken) { 25 }

    it 'creates a result' do
      result_params.merge!(rank: chicken)
      post :create, result: result_params, format: :json
      result = user.results.last
      expect(result.rank).to eq chicken
    end
  end

  context 'with legend information' do
    it 'creates a result' do
      result_params.merge!(legend: 1337)
      post :create, result: result_params, format: :json
      result = user.results.last
      expect(result.legend).to eq 1337
    end
  end

  it 'adds history' do
    post :create, result: result_params.merge(card_history: card_history), format: :json
    result = user.results.last

    expect(result.card_histories).to have(2).items

    expect(result.card_histories.first.card.name).to eq 'Shieldbearer'
    expect(result.card_histories.first).to be_opponent
    expect(result.card_histories.first.turn).to be_nil # make sure we can add card history elements without turn info

    expect(result.card_histories.second.card.name).to eq 'The Coin'
    expect(result.card_histories.second).to be_me
    expect(result.card_histories.second.turn).to eq 3
  end

  describe 'deck support' do
    let!(:miracle) { user.decks.create!(name: 'Miracle', hero: Hero.find_by_name('Rogue'), card_ids: Card.where(name: 'Gadgetzan Auctioneer').pluck(:id)) }
    let!(:handlock) { user.decks.create!(name: 'Handlock', hero: Hero.find_by_name('Warlock'), card_ids: Card.where(name: 'Mountain Giant').pluck(:id)) }

    let(:result_params) do
      {
        hero: 'Rogue',
        opponent: 'Warlock',
        mode: 'ranked',
        coin: true,
        win: true
      }
    end

    let(:card_history) do
      [
        {card_id: 'EX1_105', player: 'opponent'}, # opponent played handlock
        {card_id: 'EX1_095', player: 'me'} # I played miracle
      ]
    end

    context 'for non-arenas' do
      it 'assigns decks on upload' do
        post :create, result: result_params.merge(card_history: card_history), format: :json
        result = user.results.last

        expect(result.deck).to eq miracle
        expect(result.opponent_deck).to eq handlock
      end
    end

    context 'for arenas' do
      it 'does not assign decks on upload' do
        post :create, result: result_params.merge(mode: 'arena', card_history: card_history), format: :json
        result = user.results.last

        expect(result.deck).to be_nil
        expect(result.opponent_deck).to be_nil
      end
    end
  end

  describe 'DELETE bulk_delete' do
    let!(:first_result) { FactoryGirl.create(:result) }
    let!(:second_result) { FactoryGirl.create(:result) }

    it 'destroys the requested results' do
      expect{
        delete :bulk_delete, { result_ids: [first_result.id, second_result.id] }
      }.to change(Result, :count).by(-2)
    end

  end

end
