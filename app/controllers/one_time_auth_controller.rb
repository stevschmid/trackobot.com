class OneTimeAuthController < ApplicationController
  respond_to :json

  def create
    result = RegenerateToken.call(user: current_user, token_name: :one_time_authentication_token)
    url = profile_url(u: current_user.username, t: result.token)

    render json: {
      url: url
    }
  end
end
