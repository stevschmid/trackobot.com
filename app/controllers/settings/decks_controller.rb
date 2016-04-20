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

  def new
    @deck = policy_scope(Deck).new
    authorize @deck
  end

  def edit
    @deck = policy_scope(Deck).find(params[:id])
    authorize @deck
  end

  def update
    @deck = policy_scope(Deck).find(params[:id])
    authorize @deck
    if @deck.update_attributes(safe_params)
      redirect_to profile_settings_decks_path, flash: { success: 'Deck updated.' }
    else
      flash[:error] = "Deck couldn't be updated"
      render :edit
    end
  end

  def create
    @deck = policy_scope(Deck).new(safe_params)
    authorize @deck
    if @deck.save
      redirect_to profile_settings_decks_path, flash: { success: 'Deck added.' }
    else
      flash[:error] = "Deck couldn't be added"
      render :new
    end
  end

  def destroy
    @deck = policy_scope(Deck).find(params[:id])
    authorize @deck
    if @deck.destroy
      flash[:success] = "Deck deleted."
    else
      flash[:alert] = "Deck couldn't be deleted."
    end
    redirect_to profile_settings_decks_path
  end

  private

  def safe_params
    params.require(:deck).permit(:name, :hero_id, :card_ids => [])
  end
end
