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
      {card_id: 'GAME_005', player: 'me'}
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


  it 'adds history' do
    post :create, result: result_params.merge(card_history: card_history), format: :json
    result = user.results.last

    expect(result.card_histories).to have(2).items

    expect(result.card_histories.first.card.name).to eq 'Shieldbearer'
    expect(result.card_histories.first.player).to eq 'opponent'

    expect(result.card_histories.second.card.name).to eq 'The Coin'
  end

end
