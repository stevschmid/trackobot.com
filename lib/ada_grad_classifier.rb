class AdaGradClassifier
  class Coder
    def self.dump(clf)
      JSON.dump clf.to_hash
    end

    def self.load(obj)
      AdaGradClassifier.new JSON.load(obj, nil, symbolize_names: true)
    end
  end

  attr_accessor :weights

  def initialize(opts = nil)
    opts ||= {}
    @weights = opts[:weights] || {}
  end

  def to_hash
    {
      weights: weights
    }
  end
end
