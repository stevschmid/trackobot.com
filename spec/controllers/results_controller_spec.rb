require 'spec_helper'

describe ResultsController do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in(user)
  end

  describe 'POST create' do
    let(:result_params) do
      {
        hero: 'Shaman',
        opponent: 'Warrior',
        mode: 'ranked',
        coin: true,
        win: true,
        added: '2016-02-02T21:06:00Z'
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
      expect(result.added).to eq Time.parse('2016-02-02T21:06:00Z')
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

      expect(result.card_history_list.count).to eq 2

      expect(result.card_history_list.first.card.name).to eq 'Shieldbearer'
      expect(result.card_history_list.first.player).to eq :opponent
      expect(result.card_history_list.first.turn).to eq 0 # make sure we can add card history elements without turn info

      expect(result.card_history_list.second.card.name).to eq 'The Coin'
      expect(result.card_history_list.second.player).to eq :me
      expect(result.card_history_list.second.turn).to eq 3
    end

    describe 'card playable status' do
      let(:card) { Card.find_by_ref(card_history.first[:card_id]) }

      before do
        card.update_attributes(playable: false)
      end

      it 'mark cards as playable when they are seen for the first time' do
        expect {
          post :create, result: result_params.merge(card_history: card_history), format: :json
        }.to change { card.reload.playable? }
      end
    end

    describe 'deck support' do
      pending
    end
  end

  describe 'DELETE bulk_delete' do
    let(:result_user) { user }
    let!(:first_result) { FactoryGirl.create(:result, user: result_user) }
    let!(:second_result) { FactoryGirl.create(:result, user: result_user) }

    it 'destroys the requested results' do
      expect{
        delete :bulk_delete, { result_ids: [first_result.id, second_result.id] }
      }.to change(Result, :count).by(-2)
    end

    context 'as another user' do
      let(:result_user) { FactoryGirl.create(:user) }

      it 'gives you the finger' do
        expect {
          delete :bulk_delete, { result_ids: [first_result.id, second_result.id] }
        }.to_not change(Result, :count)
      end
    end
  end

  describe 'PUT update' do
    let(:deck1) { FactoryGirl.create(:deck) }
    let(:deck2) { FactoryGirl.create(:deck) }

    let(:result_owner) { user }
    let(:result) { FactoryGirl.create(:result, user: result_owner, deck: deck1) }

    describe 'decks' do
      describe 'new deck_id' do
        it 'changes the deck' do
          expect {
            put :update, id: result.id, result: { deck_id: deck2.id }
          }.to change { result.reload.deck }.from(deck1).to(deck2)
        end
      end

      describe 'empty deck_id' do
        it 'clears the deck' do
          expect {
            put :update, id: result.id, result: { deck_id: nil }
          }.to change { result.reload.deck }.from(deck1).to(nil)
        end
      end
    end

    describe 'tags' do
      let(:tags_array) { ['misplay', 'cool match'] }
      let(:tags) { tags_array.join ',' }

      it 'sets the tags' do
        expect {
          put :update, id: result.id, result: { tags: tags }
        }.to change { result.reload.tags.collect(&:tag) }.to eq tags_array
      end
    end

    describe 'user' do
      it 'cannot change the associated user' do
        expect {
          put :update, id: result.id, result: { user_id: user.id + 1 }
        }.not_to change { result.reload.user }
      end
    end

    describe 'result owned by somebody else' do
      let(:result_owner) { FactoryGirl.create(:user) }

      it 'denies' do
        expect {
          put :update, id: result.id, result: { deck_id: deck2.id }
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end

  end

end
