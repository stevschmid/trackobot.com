class RedeemOneTimeAuthToken
  include Interactor

  def call
    user = User.find_by_username(context.username)
    if user && check_token(user, context.token)
      RegenerateToken.call(user: user, token_name: :one_time_authentication_token)
      context.user = user
    else
      context.fail!
    end
  end

  private

  def check_token(user, token)
    Security.secure_compare(user.one_time_authentication_token, token)
  end
end
