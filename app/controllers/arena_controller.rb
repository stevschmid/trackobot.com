class ArenaController < ApplicationController

  def index
    @arenas = current_user.arenas.page(params[:page]).order('arenas.created_at DESC')
    respond_to do |format|
      format.html
      format.json do
        render json: @arenas, meta: {
          current_page: @arenas.current_page,
          next_page: @arenas.next_page,
          prev_page: @arenas.prev_page,
          total_pages: @arenas.total_pages,
          total_count: @arenas.total_count
        }
      end
    end
  end

end
