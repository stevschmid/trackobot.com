class HistoryController < ApplicationController

  def index
    @unpaged_results = current_user.results.order('results.created_at DESC')
    @results = @unpaged_results.page(params[:page])

    respond_to do |format|
      format.html
      format.json do
        render json: @results, meta: {
          current_page: @results.current_page,
          next_page: @results.next_page,
          prev_page: @results.prev_page,
          total_pages: @results.total_pages,
          total_items: @results.total_count
        }
      end
      format.csv do
        render text: @unpaged_results.to_csv
      end
    end
  end

end
