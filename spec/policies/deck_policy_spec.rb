require 'spec_helper'

require_relative 'owner_policy'

describe DeckPolicy do
  it_behaves_like :owner_policy do
    let(:model) { Deck }
  end
end
