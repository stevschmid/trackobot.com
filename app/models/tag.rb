class Tag < ActiveRecord::Base
  default_scope { order('id') }

  belongs_to :result
  validates :result, :tag, presence: true
end
