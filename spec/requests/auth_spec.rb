require 'spec_helper'

describe 'Authentication' do
  let(:password) { 'nose1234' }
  let(:user) { FactoryBot.create(:user, password: password) }

  context 'without auth' do
    it 'redirects to login' do
      get '/profile'
      expect(response).to redirect_to('/sessions/new')
    end
  end

  context 'with normal login' do
    context 'valid credentials' do
      it 'logs in' do
        post '/sessions', params: { username: user.username, password: password }
        expect(response).to redirect_to('/profile')
      end
    end

    context 'invalid credentials' do
      it 'won\'t log in' do
        post '/sessions', params: { username: user.username, password: "#{password}1" }
        expect(response.status).to eq 200
        expect(response.body).to match(/input.*username/)
      end
    end
  end

  context 'with one time auth token' do
    let(:token) { user.one_time_authentication_token }

    it 'logs in' do
      get '/profile', params: { u: user.username, t: token }
      expect(response).to redirect_to('/profile')
    end

    it 'cannot log in with a empty token' do
      user.update_attributes(one_time_authentication_token: nil)
      get '/profile', params: { u: user.username, t: '' }
      expect(response).to redirect_to('/sessions/new')
    end

    it 'cannot log in with a invalid token' do
      get '/profile', params: { u: user.username, t: 'pasterino' }
      expect(response.status).to eq 401
    end

    it 'cannot log in with the same token a second time' do
      get '/profile', params: { u: user.username, t: token }
      expect(response).to redirect_to('/profile')

      delete '/sessions'

      get '/profile', params: { u: user.username, t: token }
      expect(response.status).to eq 401
    end
  end

  context 'with an API token' do
    let(:token) { user.api_authentication_token }

    context 'with a valid token' do
      it 'logs in' do
        get '/profile/history.json', params: { username: user.username, token: token }
        expect(response.code).to eq '200'
      end

      it 'cannot delete results' do
        delete '/profile/results/1', params: { username: user.username, token: token }
        expect(response.code).to eq '401'
      end

      it 'cannot regenerate api keys' do
        put '/profile/settings/api', params: { username: user.username, token: token }
        expect(response.code).to eq '401'
      end

      it 'cannot reset the account' do
        post '/profile/settings/account/reset', params: { username: user.username, token: token, result_modes: %w[ranked casual] }
        expect(response.code).to eq '401'
      end
    end

    context 'invalid token' do
      it 'cannot log in with a empty token' do
        User.skip_callback(:save, :before, :ensure_tokens)
        user.update_attributes(api_authentication_token: nil)
        User.set_callback(:save, :before, :ensure_tokens)
        get '/profile/history.json', params: { username: user.username, token: '' }
        expect(response).to redirect_to('/sessions/new')
      end

      it 'cannot log in with a invalid token' do
        get '/profile/history.json', params: { username: user.username, token: 'swaggerino123' }
        expect(response.code).to eq '401'
      end

      it 'cannot log in with a invalid username' do
        get '/profile/history.json', params: { username: user.username + 'yo', token: token }
        expect(response.code).to eq '401'
      end
    end
  end
end
