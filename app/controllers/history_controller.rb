class HistoryController < ApplicationController

  def index
    @results = current_user.results.page(params[:page]).order('results.created_at DESC')
    # respond_with(@results)
    respond_to do |format|
      format.html
      format.json do
        render json: @results, meta: {
          current_page: @results.current_page,
          next_page: @results.next_page,
          prev_page: @results.prev_page,
          total_pages: @results.total_pages,
          total_count: @results.total_count
        }
      end
    end
  end

end
