class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :trackable

  has_many :results
  has_many :arenas

  has_many :feedbacks

  validates_presence_of :username

  has_many :notification_reads
  has_many :read_notifications, class_name: 'Notification', through: :notification_reads, source: :notification

  def unread_notifications
    Notification.where.not(id: read_notifications)
  end

  def regenerate_one_time_authentication_token
    self.one_time_authentication_token = loop do
      token = Devise.friendly_token
      break token unless self.class.where(one_time_authentication_token: token).first
    end
  end

  def regenerate_one_time_authentication_token!
    regenerate_one_time_authentication_token.tap { save }
  end

  def check_and_redeem_one_time_authentication_token(token)
    if Devise.secure_compare(one_time_authentication_token, token)
      regenerate_one_time_authentication_token!
      true
    else
      false
    end
  end
end
