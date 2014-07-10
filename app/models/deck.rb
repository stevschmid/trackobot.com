class Deck < ActiveRecord::Base
  belongs_to :hero
  belongs_to :user

  validates_presence_of :name

  has_and_belongs_to_many :cards
end
