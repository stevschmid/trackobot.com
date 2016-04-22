require 'ada_grad_classifier'

class Deck < ActiveRecord::Base

  belongs_to :hero

  serialize :classifier, AdaGradClassifier::Coder

  def to_s
    name
  end

end
