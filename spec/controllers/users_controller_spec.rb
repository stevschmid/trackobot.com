require 'spec_helper'

describe UsersController do

  describe 'PATCH rename' do
    let(:logged_in_user) { FactoryBot.create(:user) }

    before do
      request.env['HTTP_REFERER'] = '' # back
      sign_in(logged_in_user)
    end

    context 'as logged in user' do
      let(:user) { logged_in_user }

      it 'renames' do
        patch :rename, params: { user_id: user.id, user: { displayname: 'Salty Reynad' } }
        user.reload
        expect(response.status).to eq 302
        expect(user.displayname).to eq 'Salty Reynad'
      end
    end

    context 'as another user' do
      let(:user) { FactoryBot.create(:user) }

      it 'Follow the rules!' do
        patch :rename, params: { user_id: user.id, user: { displayname: 'Salty Reynad' } }
        user.reload
        expect(response.status).to eq 401
        expect(user.displayname).to_not eq 'Salty Reynad'
      end
    end
  end

end
