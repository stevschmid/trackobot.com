require 'spec_helper'

describe Deck do
  let(:user) { FactoryGirl.create(:user) }
  let(:mode) { :ranked }

  it 'has a valid factory' do
    expect(FactoryGirl.create(:deck)).to be_valid
  end


end
