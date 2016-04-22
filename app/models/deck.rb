class Deck < ActiveRecord::Base
  belongs_to :hero

  serialize :classifier, AdaGradClassifier

  validates_presence_of :hero, :name

  def to_s
    name
  end
end
