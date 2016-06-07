require 'spec_helper'

shared_examples :owner_policy do
  subject { described_class }

  let(:user) { FactoryGirl.create(:user) }
  let(:another_user) { FactoryGirl.create(:user) }

  let!(:item) { FactoryGirl.create(model, user: owner) }

  permissions :show?, :create?, :update?, :destroy? do
    context 'owner' do
      let(:owner) { user }
      specify { expect(subject).to permit(user, item) }
    end

    context 'not owner' do
      let(:owner) { another_user }
      specify { expect(subject).not_to permit(user, item) }
    end
  end

  describe 'scope' do
    let(:scope) { described_class::Scope.new(user, model).resolve }

    context 'owner' do
      let(:owner) { user }
      specify { expect(scope.count).to eq 1 }
    end

    context 'not owner' do
      let(:owner) { another_user }
      specify { expect(scope.count).to eq 0 }
    end
  end
end
