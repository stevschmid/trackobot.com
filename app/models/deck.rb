class Deck < ApplicationRecord
  enum hero: Hero::MAPPING, _suffix: true

  serialize :classifier, AdaGradClassifier

  validates_presence_of :hero, :name

  def full_name
    "#{name} #{hero.titleize}"
  end
end
