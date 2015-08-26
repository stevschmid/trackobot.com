require 'spec_helper'

describe 'Authentication' do
  let(:user) { FactoryGirl.create(:user) }

  context 'without auth' do
    it 'redirects to login' do
      get '/profile'
      expect(response).to redirect_to('/users/sign_in')
    end
  end

  context 'with one time auth token' do
    let(:token ) { user.regenerate_one_time_authentication_token! }

    it 'logs in' do
      get '/profile', u: user.username, t: token
      expect(response).to redirect_to('/profile')
    end

    it 'cannot log in with a empty token' do
      user.update_attributes(one_time_authentication_token: nil)
      get '/profile', u: user.username, t: ''
      expect(response).to redirect_to('/users/sign_in')
    end

    it 'cannot log in with a invalid token' do
      get '/profile', u: user.username, t: 'pasterino'
      expect(response).to redirect_to('/users/sign_in')
    end

    it 'cannot log in with the same token a second time' do
      get '/profile', u: user.username, t: token
      expect(response).to redirect_to('/profile')

      delete '/users/sign_out'

      get '/profile', u: user.username, t: token
      expect(response).to redirect_to('/users/sign_in')
    end
  end

  context 'with an API token' do
    let(:token) { user.api_authentication_token }

    context 'with a valid token' do
      it 'logs in' do
        get '/profile/history.json', username: user.username, token: token
        expect(response.code).to eq '200'
      end

      it 'cannot create results' do
        post '/profile/results', username: user.username, token: token
        expect(response.code).to eq '401'
      end

      it 'cannot delete results' do
        delete '/profile/results/bulk_delete', username: user.username, token: token
        expect(response.code).to eq '401'
      end

      it 'cannot update results' do
        delete '/profile/results/bulk_delete', username: user.username, token: token
        expect(response.code).to eq '401'
      end
    end

    context 'invalid token' do
      it 'cannot log in with a empty token' do
        User.skip_callback(:save, :before, :ensure_api_authentication_token)
        user.update_attributes(api_authentication_token: nil)
        User.set_callback(:save, :before, :ensure_api_authentication_token)
        get '/profile/history.json', username: user.username, token: ''
        expect(response.code).to eq '401'
      end

      it 'cannot log in with a invalid token' do
        get '/profile/history.json', username: user.username, token: 'swaggerino123'
        expect(response.code).to eq '401'
      end

      it 'cannot log in with a invalid username' do
        get '/profile/history.json', username: user.username + 'yo', token: token
        expect(response.code).to eq '401'
      end
    end
  end
end
