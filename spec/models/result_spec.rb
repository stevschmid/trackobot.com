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

  describe 'card_history associations' do
    let(:result) { FactoryGirl.create(:result, mode: :ranked) }

    let!(:first_play) { FactoryGirl.create(:card_history, result: result) }
    let!(:second_play) { FactoryGirl.create(:card_history, result: result) }

    it 'has card_histories in the right order' do
      expect(result.card_histories.to_a).to eq [first_play, second_play]
    end

    it 'destroys associated card_histories' do
      expect { result.destroy }.to change { result.card_histories.count }.by(-2)
    end
  end

end
