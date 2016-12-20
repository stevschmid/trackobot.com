class Deck < ApplicationRecord
  belongs_to :hero

  serialize :classifier, AdaGradClassifier

  validates_presence_of :hero, :name

  def self.reset_all_classifiers!
    Deck.update_all(classifier: nil)
  end

  def full_name
    "#{name} #{hero.name}"
  end
end
