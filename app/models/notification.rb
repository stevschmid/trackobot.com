class Notification < ActiveRecord::Base
  validates_presence_of :message

  has_many :notification_reads
end
