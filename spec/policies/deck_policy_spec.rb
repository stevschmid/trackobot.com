require 'spec_helper'

require_relative 'owner_policy'

describe DeckPolicy do

  subject { described_class }

  let(:user) { FactoryGirl.create(:user) }
  let(:item) { Deck.first }

  permissions :show? do
    specify { expect(subject).to permit(user, item) }
  end

  permissions :create?, :update?, :destroy? do
    specify { expect(subject).not_to permit(user, item) }
  end

end
