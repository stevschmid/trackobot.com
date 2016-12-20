require 'spec_helper'

describe ResultsController do
  let(:user) { FactoryGirl.create(:user) }

  let(:rogue) { Hero.find_by_name('Rogue') }
  let(:warlock) { Hero.find_by_name('Warlock') }

  let(:miracle) { Deck.find_by!(key: 'miracle', hero: rogue) }
  let(:zoo) { Deck.find_by!(key: 'zoo', hero: warlock) }
  let(:reno) { Deck.find_by!(key: 'reno', hero: warlock) }

  let(:mode) { 'ranked' }
  let(:card_history) { [] }

  let(:result_params) do
    {
      hero: warlock.name,
      opponent: rogue.name,
      mode: mode,
      coin: true,
      win: true,
      added: '2016-02-02T21:06:00Z',
      card_history: card_history,
      note: 'test note'
    }
  end

  before do
    sign_in(user)
  end

  describe 'POST create' do
    it 'creates a result' do
      post :create, result: result_params, format: :json
      result = user.results.last

      expect(result.hero.name).to eq warlock.name
      expect(result.opponent.name).to eq rogue.name
      expect(result.mode).to eq mode
      expect(result.coin).to eq true
      expect(result.win).to eq true
      expect(result.note).to eq 'test note'
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

    describe 'card history' do
      let(:card_history) do
        [
          {card_id: 'EX1_405', player: 'opponent'},
          {card_id: 'GAME_005', player: 'me', turn: 3}
        ]
      end

      it 'adds history' do
        post :create, result: result_params, format: :json
        result = user.results.last
        expect(result.card_history_list).to eq(card_history)
      end
    end

    describe 'deck support' do
      let(:card_history) do
        [
          {card_id: 'EX1_105', player: 'opponent'}, # opponent played handlock
          {card_id: 'EX1_095', player: 'me'} # I played miracle
        ]
      end

      before do
        ClassifyDeckForHero
        stub_const('ClassifyDeckForHero::MIN_CARDS_FOR_PREDICTION', 1)
        stub_const('ClassifyDeckForHero::MIN_CARDS_FOR_LEARNING', 1)

        # learn the classifier
        post :create, result: result_params, format: :json
        result = assigns(:result)
        classify = ClassifyDeckForResult.new(result)
        classify.learn_deck_for_player! zoo
        classify.learn_deck_for_opponent! miracle
      end

      describe 'auto inferral' do
        context 'default (non-arena)' do
          it 'assigns decks on upload' do
            post :create, result: result_params, format: :json
            result = assigns(:result)

            expect(result.deck).to eq zoo
            expect(result.opponent_deck).to eq miracle
          end
        end

        context 'for arenas' do
          let(:mode) { 'arena' }

          it 'does not assign decks on upload' do
            post :create, result: result_params, format: :json
            result = assigns(:result)

            expect(result.deck).to eq nil
            expect(result.opponent_deck).to eq nil
          end
        end
      end

      describe 'decks supplied' do
        it 'overrides the auto inferring algorithm' do
          post :create, result: result_params.merge(deck_id: reno.id), format: :json
          result = assigns(:result)
          expect(result.deck).to eq reno
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let(:mode) { :ranked }
    let!(:result) { FactoryGirl.create(:result, user: result_user, mode: mode) }

    context 'my result' do
      let(:result_user) { user }
      specify {
        expect { delete :destroy, id: result.id }.to change(Result, :count).by(-1)
      }

      describe 'arena' do
        let(:mode) { :arena }
        before do
          AssignArenaToResult.call(result: result)
          result.save!
        end

        context 'last result' do
          specify {
            expect { delete :destroy, id: result.id }.to change(Arena, :count).by(-1)
          }
        end

        context 'not last result' do
          before { result.arena.results << FactoryGirl.create(:result, mode: :arena) }
          specify {
            expect { delete :destroy, id: result.id }.not_to change(Arena, :count)
          }
        end
      end
    end

    context 'foreign result' do
      let(:result_user) { FactoryGirl.create(:user) }
      specify {
        expect {
          delete :destroy, id: result.id
        }.to raise_error(ActiveRecord::RecordNotFound)
      }
    end
  end

  describe 'PUT update' do
    let(:result_owner) { user }
    let!(:result) { FactoryGirl.create(:result, user: result_owner, hero: warlock, opponent: rogue, deck_id: existing_deck_id, mode: mode) }

    let(:existing_deck_id) { zoo.id }
    let(:new_deck_id) { reno.id }

    let(:result_params) { { deck_id: new_deck_id } }

    subject { put :update, id: result.id, result: result_params, format: :json }

    describe 'decks' do
      describe 'new deck_id' do
        let(:new_deck_id) { reno.id }

        it 'changes the deck' do
          expect { subject }.to change { result.reload.deck }.from(zoo).to(reno)
        end

        context 'new deck by wrong class' do
          let(:new_deck_id) { miracle.id }

          it 'does nothing' do
            expect { subject }.not_to change { result.reload.deck }.from(zoo)
          end
        end
      end

      describe 'empty deck_id' do
        let(:new_deck_id) { nil }

        it 'clears the deck' do
          expect { subject }.to change { result.reload.deck_id }.from(existing_deck_id).to(nil)
        end
      end

      describe 'deck learning' do
        context 'no change' do
          let(:new_deck_id) { existing_deck_id }

          it 'does not learn' do
            expect(ClassifyDeckForResult).not_to receive(:new)
            subject
          end
        end

        context 'change' do
          let(:new_deck_id) { reno.id }

          before do
            result # to ensure result is created before expectations
          end

          it 'learns the deck provided' do
            classify = double('classify')
            expect(ClassifyDeckForResult).to receive(:new).and_return(classify)
            expect(classify).to receive(:learn_deck_for_player!).with(reno)
            subject
          end

          context 'no deck' do
            let(:new_deck_id) { nil }

            it 'learns that no deck matches' do
              classify = double('classify')
              expect(ClassifyDeckForResult).to receive(:new).and_return(classify)
              expect(classify).to receive(:learn_deck_for_player!).with(nil)
              subject
            end
          end

          context 'arena' do
            let(:existing_deck_id) { nil }
            let(:new_deck_id) { reno.id }
            let(:mode) { 'arena' }

            it 'ignores decks on arena' do
              expect(ClassifyDeckForResult).not_to receive(:new)
              subject
            end
          end

          describe 'protection' do
            let(:created_at) { 10.hours.ago }
            let(:updated_at) { created_at }

            before do
              result.update_attributes(created_at: created_at, updated_at: updated_at)
            end

            context 'learning twice after a short period' do
              let(:updated_at) { 15.minutes.ago }
              it 'does not learn' do
                expect(ClassifyDeckForResult).not_to receive(:new)
                subject
              end
            end

            context 'learning twice after a long period' do
              let(:updated_at) { 2.hours.ago }

              subject do
                put :update, id: result.id, result: { deck_id: new_deck_id }, format: :json
                put :update, id: result.id, result: { deck_id: existing_deck_id }, format: :json
              end

              context 'default' do
                it 'learns only once' do
                  expect(ClassifyDeckForResult).to receive(:new).once.and_call_original
                  subject
                end
              end

              context 'as admin' do
                before do
                  user.update_attributes(admin: true)
                end
                let(:updated_at) { 2.hours.ago }
                it 'learns always' do
                  expect(ClassifyDeckForResult).to receive(:new).twice.and_call_original
                  subject
                end
              end
            end
          end
        end
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
          put :update, id: result.id, result: { deck_id: nil }
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end

  end

end
