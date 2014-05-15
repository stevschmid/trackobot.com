class ResultsController < ApplicationController
  respond_to :json, :html

  def create
    @result = current_user.results.create(safe_params)
    respond_with(:profile, @result)
  end

  private

  def safe_params
    params.require(:result).permit(:mode, :win, :hero, :opponent, :coin)
  end

end
