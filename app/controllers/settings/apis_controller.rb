class Settings::ApisController < ApplicationController
  include ApiDenier
  before_action :deny_api_calls!

  def show
  end

  def update
    if params[:regenerate_api_token].present?
      RegenerateToken.call(user: current_user, token_name: :api_authentication_token)
      redirect_to profile_settings_api_path, flash: {success: 'Your API token was regenerated successfully.'}
    end
  end
end
