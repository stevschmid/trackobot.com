class GetUnreadNotifications
  include Interactor

  def call
    read_ids = context.user.notification_reads.map(&:notification_id)
    context.notifications = Notification.active.where.not(id: read_ids)
  end
end
