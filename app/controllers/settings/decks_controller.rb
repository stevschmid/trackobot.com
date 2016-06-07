class Settings::DecksController < ApplicationController

  after_action :verify_policy_scoped
  after_action :verify_authorized, except: :index

  def index
    @decks = policy_scope(Deck).order(:hero_id)
    respond_to do |format|
      format.html
      format.json do
        render json: @decks
      end
    end
  end

end
