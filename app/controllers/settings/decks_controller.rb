class Settings::DecksController < ApplicationController
  def index
    @decks = current_user.decks.order(:hero_id)
  end

  def new
    @deck = current_user.decks.new
  end

  def edit
    @deck = current_user.decks.find(params[:id])
  end

  def update
    @deck = current_user.decks.find(params[:id])
    if @deck.update_attributes(safe_params)
      redirect_to profile_settings_decks_path, flash: { success: 'Deck updated.' }
    else
      flash[:error] = "Deck couldn't be updated"
      render :edit
    end
  end

  def create
    @deck = current_user.decks.new(safe_params)
    if @deck.save
      redirect_to profile_settings_decks_path, flash: { success: 'Deck added.' }
    else
      flash[:error] = "Deck couldn't be added"
      render :new
    end
  end

  def destroy
    @deck = current_user.decks.find(params[:id])
    if @deck.destroy
      flash[:success] = "Deck deleted."
    else
      flash[:alert] = "Deck couldn't be deleted."
    end
    redirect_to profile_settings_decks_path
  end

  def import_decks
    begin
      decks_array = JSON.parse(params[:decks_json])
      decks_array.each do |deck|
        current_user.decks.create(deck)
      end
      flash[:success] = "Decks successfully imported."
    rescue
      flash[:error] = "Decks couldn't be imported"
    end
    redirect_to profile_settings_decks_path
  end

  def export
    @decks_json = current_user.decks.collect{|deck| DeckSerializer.new(deck, root: false).as_json}.to_json
  end

  private

  def safe_params
    params.require(:deck).permit(:name, :hero_id, :card_ids => [])
  end
end
