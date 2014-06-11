class SettingsController < ApplicationController
  def show
  end

  def update
    if params[:regenerate_api_token].present?
      current_user.regenerate_api_authentication_token
      current_user.save!
      redirect_to profile_settings_path, flash: {success: 'Your API token was regenerated successfully.'}
    end
  end
end
