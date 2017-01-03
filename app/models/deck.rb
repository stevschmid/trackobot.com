require 'ada_grad_classifier'

class Deck < ApplicationRecord
  enum hero: Hero::MAPPING, _suffix: true

  class AdaGradClassifier::Serializer
    def self.load(str)
      args = {}
      args = JSON.parse(str, symbolize_names: true) unless str.blank?
      AdaGradClassifier.new args
    end

    def self.dump(obj)
      obj.to_json
    end
  end

  serialize :classifier, AdaGradClassifier::Serializer

  validates_presence_of :hero, :name

  def full_name
    "#{name} #{hero.titleize}"
  end
end
