require 'spec_helper'

require_relative 'owner_policy'

describe UserPolicy do
  subject { described_class }

  let(:user) { FactoryBot.create(:user) }
  let(:another_user) { FactoryBot.create(:user) }

  permissions :show?, :create?, :update?, :destroy? do
    specify do
      expect(subject).to permit(user, user)
      expect(subject).not_to permit(user, another_user)
    end
  end
end
