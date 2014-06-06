class NotificationsController < ApplicationController
  def mark_as_read
    current_user.read_notifications << Notification.find(params[:id])
    render nothing: true
  end
end
