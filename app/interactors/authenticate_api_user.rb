class AuthenticateAPIUser
  include Interactor

  def call
    user = User.find_by_username(context.username)
    if user && check_token(user, context.token)
      context.user = user
    else
      context.fail!
    end
  end

  private

  def check_token(user, token)
    Security.secure_compare(user.api_authentication_token, token)
  end
end
