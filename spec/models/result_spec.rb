require 'spec_helper'

describe Result do
  let(:result) { FactoryGirl.create(:result) }

  describe 'arena result' do
    before { result.arena! }

    it 'should not be deleted until we figure out how to manage arena results' do
      expect{result.destroy}.to_not change(Result, :count).by(-1)
    end
  end

  describe 'card_history associations' do
    let!(:first_play) do
      FactoryGirl.create(:card_history, result: result)
    end

    let!(:second_play) do
      FactoryGirl.create(:card_history, result: result)
    end

    it 'should have the right card_histories in the right order' do
      expect(result.card_histories.to_a).to eq [first_play, second_play]
    end

    it 'should destroy associated card_histories' do
      card_histories = result.card_histories.to_a
      result.destroy
      expect(card_histories).to_not be_empty
      card_histories.each do |card_history|
        expect(CardHistory.where(id: card_history.id)).to be_empty
      end
    end

    describe 'arena result' do
      before { result.arena! }

      its 'card_histories should not be deleted' do
        card_histories = result.card_histories.to_a
        result.destroy
        expect(card_histories).to_not be_empty
        card_histories.each do |card_history|
          expect(CardHistory.where(id: card_history.id)).to_not be_empty
        end
      end

    end

  end

end
