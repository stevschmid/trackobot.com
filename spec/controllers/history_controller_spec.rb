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
      subject { json[:history].first }

      its([:id]) { should eq(result.id) }
      its([:mode]) { should eq(result.mode) }
      its([:hero]) { should eq(result.hero.name) }
      its([:opponent]) { should eq(result.opponent.name) }
      its([:coin]) { should eq(result.coin) }
      its([:result]) { should eq(result.win ? 'win' : 'loss') }
      its([:added]) { should eq(result.created_at.iso8601(3)) }

      context 'arena' do
        let!(:result) { FactoryGirl.create(:result, mode: :arena, user: user) }
        its([:arena_id]) { should eq(result.arena.id) }
      end

      context 'no arena' do
        let!(:result) { FactoryGirl.create(:result, mode: :ranked, user: user) }
        it { should_not include(:arena_id) }
      end
    end
  end

end
