require 'security'

class RegenerateToken
  include Interactor

  def call
    token_name = context.token_name
    user = context.user

    new_token = loop do
      token = Security.friendly_token
      break token unless User.where(token_name => token).exists?
    end

    user.update_attributes!(token_name => new_token)

    context.token = new_token
  end
end
