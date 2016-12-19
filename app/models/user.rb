class User < ActiveRecord::Base
  has_many :results
  has_many :arenas
  has_many :custom_decks
  has_many :notification_reads

  validates_presence_of :username

  before_save :ensure_tokens

  attr_accessor :password
  validates_presence_of :password, on: :create
  before_save :encrypt_password, if: -> { password.present? }

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
