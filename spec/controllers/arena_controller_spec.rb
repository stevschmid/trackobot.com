require 'spec_helper'

describe ArenaController do

  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in(user)
  end

  context 'json' do
    let!(:result) { FactoryGirl.create(:result, mode: :arena, user: user) }
    let(:arena) { result.arena }

    before do
      get :index, format: :json
    end

    let(:json) { JSON.parse(response.body, symbolize_names: true) }

    it 'has arenas' do
      expect(json[:arena].count).to eq 1
    end

    it 'has meta pagination information' do
      expect(json[:meta].keys).to include(:current_page, :next_page, :prev_page, :total_pages, :total_items)
    end

    describe 'arena structure' do
      subject { json[:arena].first }

      its([:id]) { should eq(arena.id) }
      its([:hero]) { should eq(arena.hero.name) }
      its([:wins]) { should eq(arena.wins.count) }
      its([:losses]) { should eq(arena.losses.count) }
      specify { expect(subject[:results].count).to eq 1 }
    end
  end

end
