class NotificationsController < ApplicationController
  def mark_as_read
    current_user.read_notifications << Notification.find(params[:id])
    head :ok
  end
end
