class OneTimeAuthController < ApplicationController
  respond_to :json

  def create
    result = RegenerateToken.call(user: current_user, token_name: :one_time_authentication_token)
    @url = profile_url(u: current_user.username, t: result.token)
    respond_with(@url)
  end
end
