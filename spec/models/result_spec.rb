require 'spec_helper'

describe Result do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:result)).to be_valid
  end

  describe 'update' do
    it 'touches user' do
      user = create(:user)
      result = build(:result, user: user)
      Timecop.freeze(Date.today + 30) do
        result.save
      end
      expect(user.updated_at).to eq(result.updated_at)
    end
  end
end
