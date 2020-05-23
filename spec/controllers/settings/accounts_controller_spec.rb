require 'spec_helper'

describe Settings::AccountsController do

  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  before do
    Result.modes.each do |mode, id|
      FactoryBot.create(:result, mode: mode, user: user)
      FactoryBot.create(:result, mode: mode, user: other_user)
    end
  end

  describe 'POST reset' do
    let(:reset_modes) { %w[ranked casual] }

    subject { post :reset, params: { reset_modes: reset_modes } }

    it 'deletes the results specified by reset_modes' do
      expect {
        subject
      }.to change { user.results.ranked.count + user.results.casual.count }.to(0)
    end

    it 'leaves results by other users unaffected' do
      expect {
        subject
      }.not_to change { other_user.results.count }
    end

    it 'does not delete the results excluded in reset_modes' do
      expect {
        subject
      }.not_to change { user.results.practice.count + user.results.arena.count + user.results.friendly.count }
    end

    describe 'arena' do
      before { FactoryBot.create(:result_with_arena, user: user) }

      context 'arena specified' do
        let(:reset_modes) { %w[arena] }
        it 'deletes arena runs' do
          expect {
            subject
          }.to change { user.arenas.count }.to(0)
        end
      end

      context 'arena unspecified' do
        let(:reset_modes) { %w[ranked] }
        it 'does not delete arena runs' do
          expect {
            subject
          }.not_to change { user.arenas.count }
        end
      end
    end
  end

end
