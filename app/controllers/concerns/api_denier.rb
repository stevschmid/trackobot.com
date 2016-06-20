module ApiDenier
  extend ActiveSupport::Concern

  def deny_api_calls!
    head :unauthorized if params[:token].present?
  end
end
