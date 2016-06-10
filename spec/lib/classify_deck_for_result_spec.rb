require 'spec_helper'

describe ClassifyDeckForResult do

  include ResultHelpers

  let(:user) { FactoryGirl.create(:user) }

  let(:player_cards) { ['Totem Golem', 'Lightning Bolt', 'Lightning Bolt'] }
  let(:opponent_cards) { ['Fiery War Axe'] }
  let(:result) { build_result_with_history('Shaman', 'Warrior', :ranked, user, me: player_cards,  opponent: opponent_cards) }

  subject { described_class.new(result) }

  it 'uses the card list for the specified player' do
    expect(ClassifyDeckForHero).to receive(:new).with(Hero.find_by_name('Shaman'), { 'AT_052' => 1, 'EX1_238' => 2 }).and_call_original
    subject.predict_deck_for_player

    expect(ClassifyDeckForHero).to receive(:new).with(Hero.find_by_name('Warrior'), { 'CS2_106' => 1 }).and_call_original
    subject.predict_deck_for_opponent
  end

  describe 'hero powers' do
    let(:player_cards) { ['Totem Golem', 'Totemic Call'] }

    it 'ignores hero powers' do
      expect(ClassifyDeckForHero).to receive(:new).with(anything, { 'AT_052' => 1 }).and_call_original
      subject.predict_deck_for_player
    end
  end

end
