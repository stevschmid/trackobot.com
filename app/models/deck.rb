class Deck < ApplicationRecord
  belongs_to :hero

  serialize :classifier, AdaGradClassifier

  validates_presence_of :hero, :name

  def full_name
    "#{name} #{hero.name}"
  end
end
