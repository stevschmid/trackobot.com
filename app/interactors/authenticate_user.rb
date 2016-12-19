class AuthenticateUser
  include Interactor

  def call
    user = User.find_by_username(context.username)
    if user && check_password(user, context.password)
      context.user = user
    else
      context.fail! message: 'Failed to login'
    end
  end

  private

  def check_password(user, password)
    Security.check_password(user.encrypted_password, password)
  rescue
    false
  end
end
