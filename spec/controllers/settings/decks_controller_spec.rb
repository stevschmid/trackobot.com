require 'spec_helper'

describe Settings::DecksController do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in(user)
  end

  let(:import_json) do
    '[
      {"name":"test","hero_id":3,"card_ids":[235]},
      {"name":"test1","hero_id":3,"card_ids":[235]},
      {"name":"test2","hero_id":1,"card_ids":[235]}
    ]'
  end

  it 'successfully imports multiple decks' do
    post :import_decks, decks_json: import_json
    expect(user.decks.count).to eq 3
  end
end
