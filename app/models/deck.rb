class Deck < ActiveRecord::Base
  belongs_to :hero

  serialize :classifier, AdaGradClassifier

  def to_s
    name
  end
end
