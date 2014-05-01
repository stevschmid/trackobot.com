class HistoryController < ApplicationController
  respond_to :json, :html

  def index
    @results = current_user.results.page(params[:page])
    respond_with(@results)
  end
end
