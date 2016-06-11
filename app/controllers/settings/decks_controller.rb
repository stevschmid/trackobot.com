class Settings::DecksController < ApplicationController

  after_action :verify_policy_scoped, except: :toggle

  def index
    @decks = policy_scope(Deck)
    respond_to do |format|
      format.html
      format.json do
        render json: @decks
      end
    end
  end

  def toggle
    deck_tracking = params[:user][:deck_tracking]
    current_user.deck_tracking = deck_tracking
    current_user.save!
    redirect_to profile_settings_decks_path, flash: {success: 'Saved!'}
  end

end
