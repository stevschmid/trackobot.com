class User < ActiveRecord::Base
  has_many :results
  has_many :arenas

  has_many :custom_decks

  has_many :notification_reads
  has_many :read_notifications, class_name: 'Notification', through: :notification_reads, source: :notification

  validates_presence_of :username

  before_save :ensure_tokens

  attr_accessor :password
  validates_presence_of :password, on: :create
  before_save :encrypt_password, if: -> { password.present? }

  def unread_notifications
    Notification.where.not(id: read_notifications)
                .where.not(hidden: true)
  end

  def encrypt_password
    self.encrypted_password = Security.hash_password(password)
  end

  def ensure_tokens
    %i[api_authentication_token one_time_authentication_token].each do |token|
      if send(token).blank?
        RegenerateToken.call(user: self, token_name: token)
        reload
      end
    end
  end
end
