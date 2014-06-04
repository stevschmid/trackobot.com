class Feedback < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :message
end
