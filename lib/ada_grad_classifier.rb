class AdaGradClassifier
  class HashVector < Hash
    def dot(other)
      dup_keys = self.keys & other.keys
      dup_keys.inject(0.0) do |sum, key|
        sum + self[key]*other[key]
      end
    end

    def *(scalar)
      Hash[self.collect do |key, value|
        [key, value * scalar]
      end]
    end
  end

  attr_reader :sum_of_squared_gradients, :master_learn_rate, :weights

  def initialize(master_learn_rate: 1.0)
    @master_learn_rate = master_learn_rate
    @sum_of_squared_gradients = HashVector.new(0.0)
    @weights = HashVector.new(0.0)
  end

  def train(x, y)
    raise "y must be -1 or 1" unless [-1, 1].include?(y)

    # make sure input is a hash vector
    x = HashVector[x]

    # compute gradient at time t and add it to our history
    gradient = self.class.compute_gradient(x, y, weights)
    gradient.each_key do |key, g|
      @sum_of_squared_gradients[key] += gradient[key] ** 2
    end

    # now compute new weight vector
    gradient.each_key do |key|
      @weights[key] -= master_learn_rate / Math.sqrt(Float::EPSILON + @sum_of_squared_gradients[key]) * gradient[key]
    end
  end

  def predict(x)
    weights.dot(HashVector[x]) > 0.0 ? 1 : -1
  end

  def predict_score(x)
    weights.dot(HashVector[x])
  end

  def self.compute_gradient(x, y, w)
    # hinge loss max(0, 1 - y*w*t)
    case
    when y * w.dot(x) >= 1
      HashVector[w.keys.collect do |key|
        [key, 0.0]
      end]
    else
      x * -y
    end
  end

  # for saving/restoring
  def self.dump(clf)
    JSON.dump clf.export
  end

  def self.load(obj)
    AdaGradClassifier.new.tap do |clf|
      clf.import JSON.load(obj, nil, symbolize_names: true) if obj
    end
  end

  def import(settings = {})
    @master_learn_rate = settings[:master_learn_rate] if settings[:master_learn_rate]

    @sum_of_squared_gradients = settings[:sum_of_squared_gradients].dup if settings[:sum_of_squared_gradients]
    @sum_of_squared_gradients.default = 0.0

    @weights = settings[:weights].dup if settings[:weights]
    @weights.default = 0.0
  end

  def export
    {
      master_learn_rate: @master_learn_rate,
      sum_of_squared_gradients: @sum_of_squared_gradients,
      weights: @weights
    }
  end

end

