class Notification < ActiveRecord::Base
  validates_presence_of :message
  scope :active, -> { where('hidden = ? AND created_at >= ?', false, 7.days.ago) }
end
