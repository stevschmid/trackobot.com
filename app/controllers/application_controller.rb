require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :follow_the_rules!

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :authenticate_via_one_time_token, if: -> { params[:u].present? && params[:t].present? }
  before_action :authenticate_via_api_token, if: -> { params[:username].present? && params[:token].present? }
  before_action :authenticate_via_http_basic
  before_action :authenticate_user!

  private

  def authenticate_via_http_basic
    authenticate_with_http_basic do |username, password|
      result = AuthenticateUser.call(username: username, password: password)
      if result.success?
        @current_user = result.user
      end
    end
  end

  def authenticate_user!
    if current_user.nil?
      redirect_to new_sessions_path, flash: { error: 'You need to log in first!' }
      return
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @current_user
  end

  def authenticate_via_one_time_token
    result = RedeemOneTimeAuthToken.call(username: params[:u], token: params[:t])
    if result.success?
      sign_in(result.user)
      redirect_to request.path
    else
      follow_the_rules!
    end
  end

  def authenticate_via_api_token
    result = AuthenticateAPIUser.call(username: params[:username], token: params[:token])
    if result.success?
      @current_user = result.user
    else
      follow_the_rules!
    end
  end

  def follow_the_rules!
    render body: 'Unauthorized', status: :unauthorized
  end

  def sign_in(user)
    session[:user_id] = user.id
  end
end
