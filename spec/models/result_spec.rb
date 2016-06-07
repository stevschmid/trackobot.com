require 'spec_helper'

describe Result do

  describe 'arena result' do
    let(:result) { FactoryGirl.create(:result, mode: :arena) }
    let(:arena) { result.arena }

    context 'result is the last remaining result of arena' do
      it 'deletes the arena' do
        expect { result.destroy }.to change { arena.destroyed? }
      end
    end

    context 'result is one among many results of arena' do
      before do
        2.times { FactoryGirl.create(:result, arena: arena) }
      end

      it 'does not delete the arena' do
        expect { result.destroy }.to_not change { arena.destroyed? }
      end
    end
  end

  describe 'card history list' do
    let(:first_play) { FactoryGirl.build(:card_history_entry, player: :me) }
    let(:second_play) { FactoryGirl.build(:card_history_entry, player: :opponent) }

    let(:result) { FactoryGirl.create(:result, mode: :ranked, card_history_list: [first_play, second_play]) }

    it 'has card_history_list in the right order' do
      expect(result.card_history_list.collect(&:player)).to eq [:me, :opponent]
    end
  end

  describe 'deck assignment' do
    pending
  end

end
