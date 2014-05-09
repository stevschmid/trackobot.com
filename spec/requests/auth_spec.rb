require 'spec_helper'

describe 'Authentication' do
  let(:user) { FactoryGirl.create(:user) }

  context 'without auth' do
    it 'redirects to login' do
      get '/'
      expect(response).to redirect_to('/users/sign_in')
    end
  end

  context 'with one time auth token' do
    let(:token ) { user.regenerate_one_time_authentication_token! }

    it 'logs in' do
      get '/', u: user.username, t: token
      expect(response.code).to redirect_to('/')
    end

    it 'cannot log in with a empty token' do
      user.update_attributes(one_time_authentication_token: nil)
      get '/', u: user.username, t: ''
      expect(response).to redirect_to('/users/sign_in')
    end

    it 'cannot log in with the same token a second time' do
      get '/', u: user.username, t: token
      expect(response.code).to redirect_to('/')

      delete '/users/sign_out'

      get '/', u: user.username, t: token
      expect(response).to redirect_to('/users/sign_in')
    end

  end
end
