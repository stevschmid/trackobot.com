class ArenaController < ApplicationController
  include Meta

  def index
    @arenas = current_user.arenas.page(params[:page]).order('arenas.created_at DESC')
    respond_to do |format|
      format.html
      format.json do
        render json: @arenas, meta: meta(@arenas)
      end
    end
  end
end
