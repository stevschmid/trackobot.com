require 'spec_helper'

describe Settings::DecksController do

  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  context 'json' do
    let(:json) { JSON.parse(response.body, symbolize_names: true) }
    subject { json[:decks].first }

    before do
      get :index, format: :json
    end

    specify { expect(Deck.all.collect(&:name)).to include(subject[:name]) }
  end

  context 'html' do
    before do
      get :index
    end

    subject { assigns(:decks) }

    it { is_expected.not_to be_empty }
  end

end
