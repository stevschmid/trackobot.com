class ArenaController < ApplicationController

  respond_to :json, :html

  def index
    @arenas = current_user.arenas.page(params[:page])
    respond_with(@arenas)
  end
end
