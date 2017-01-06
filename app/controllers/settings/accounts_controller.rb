class Settings::AccountsController < ApplicationController
  include ApiDenier
  before_action :deny_api_calls!

  after_action :verify_policy_scoped, except: :show

  def show
  end

  def reset
    results = policy_scope(Result)

    reset_modes = params[:reset_modes] || []
    reset_modes.each do |reset_mode|
      next unless Result.modes.include?(reset_mode)

      selected_results = results.where(mode: Result.modes[reset_mode])
      selected_results.destroy_all

      if reset_mode == 'arena'
        arenas = policy_scope(Arena)
        arenas.destroy_all
      end
    end

    redirect_to profile_settings_account_path, flash: {success: 'Your account was reset successfully.'}
  end

end
