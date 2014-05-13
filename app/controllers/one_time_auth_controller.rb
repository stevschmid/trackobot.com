class OneTimeAuthController < ApplicationController
  respond_to :json

  def create
    token = current_user.regenerate_one_time_authentication_token!
    @url = profile_url(u: current_user.username, t: token)
    respond_with(@url)
  end
end
