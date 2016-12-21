require 'spec_helper'

describe ClassifyDeckForResult do

  include ResultHelper

  let(:user) { FactoryGirl.create(:user) }

  let(:player_cards) { ['Totem Golem', 'Lightning Bolt', 'Lightning Bolt'] }
  let(:opponent_cards) { ['Fiery War Axe'] }
  let(:result) { build_result_with_history('shaman', 'warrior', :ranked, user, me: player_cards,  opponent: opponent_cards) }

  subject { described_class.new(result) }

  it 'uses the card list for the specified player' do
    expect(ClassifyDeckForHero).to receive(:new).with('shaman', { 'AT_052' => 1, 'EX1_238' => 2 }).and_call_original
    subject.predict_deck_for_player

    expect(ClassifyDeckForHero).to receive(:new).with('warrior', { 'CS2_106' => 1 }).and_call_original
    subject.predict_deck_for_opponent
  end

  describe 'card filter' do
    context 'hero powers' do
      let(:player_cards) { ['Totem Golem', 'Totemic Call'] }

      specify {
        expect(ClassifyDeckForHero).to receive(:new).with(anything, { 'AT_052' => 1 }).and_call_original
        subject.predict_deck_for_player
      }
    end

    context 'coin' do
      let(:player_cards) { ['Totem Golem', 'The Coin'] }

      specify {
        expect(ClassifyDeckForHero).to receive(:new).with(anything, { 'AT_052' => 1 }).and_call_original
        subject.predict_deck_for_player
      }
    end

    context 'cards from other classes' do
      context 'player' do
        let(:player_cards) { ['Totem Golem', 'Shield Slam', 'Abusive Sergeant'] }
        specify {
          expect(ClassifyDeckForHero).to receive(:new).with(anything, { 'AT_052' => 1, 'CS2_188' => 1 }).and_call_original
          subject.predict_deck_for_player
        }
      end

      context 'opponent' do
        let(:opponent_cards) { ['Fiery War Axe', 'Totem Golem'] }
        specify {
          expect(ClassifyDeckForHero).to receive(:new).with(anything, { 'CS2_106' => 1 }).and_call_original
          subject.predict_deck_for_opponent
        }
      end
    end

  end

end
