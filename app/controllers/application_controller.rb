class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :authenticate_via_one_time_token, if: -> { params[:u].present? && params[:t].present? }
  before_action :authenticate_user!

  private

  def authenticate_via_one_time_token
    token = params[:t]
    user = User.find_by_username(params[:u])
    if user && user.check_and_redeem_one_time_authentication_token(token)
      sign_in(user)
    end
  end
end
