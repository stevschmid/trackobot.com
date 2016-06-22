class CustomDeck < ActiveRecord::Base
  belongs_to :user
  belongs_to :hero

  has_and_belongs_to_many :cards

  validates_presence_of :hero, :name

  def to_s
    name
  end

  def full_name
    "#{name}"
  end
end
