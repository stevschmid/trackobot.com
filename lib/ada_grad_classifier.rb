class AdaGradClassifier
  attr_reader :sum_of_squared_gradients, :master_learn_rate, :weights

  def initialize(master_learn_rate: 1.0, sum_of_squared_gradients: {}, weights: {})
    @master_learn_rate                = master_learn_rate
    @sum_of_squared_gradients         = HashWithIndifferentAccess.new(sum_of_squared_gradients)
    @sum_of_squared_gradients.default = 0.0
    @weights                          = HashWithIndifferentAccess.new(weights)
    @weights.default                  = 0.0
  end

  def scale_sum_gradient_by(scalar)
    @sum_of_squared_gradients = AdaGradClassifier.hash_scalar_mult(@sum_of_squared_gradients, scalar)
  end

  def train(x, y)
    raise "y must be -1 or 1" unless [-1, 1].include?(y)

    # compute gradient at time t and add it to our history
    gradient = AdaGradClassifier.compute_gradient(x, y, weights)
    gradient.each_key do |key|
      @sum_of_squared_gradients[key] += gradient[key] ** 2
    end

    # now compute new weight vector
    gradient.each_key do |key|
      @weights[key] -= master_learn_rate / Math.sqrt(Float::EPSILON + @sum_of_squared_gradients[key]) * gradient[key]
    end
  end

  def predict(x)
    predict_score(x) > 0.0 ? 1 : -1
  end

  def predict_score(x)
    AdaGradClassifier.dot(weights, x)
  end

  def self.compute_gradient(x, y, w)
    # hinge loss max(0, 1 - y*w*t)
    case
    when y * hash_dot_hash(w, x) >= 1
      HashWithIndifferentAccess[w.keys.collect { |key| [key, 0.0] }]
    else
      hash_scalar_mult(x, -y)
    end
  end

  def self.hash_scalar_mult(h, scalar)
    h.dup.tap do |res|
      res.each_key do |key|
        res[key] *= scalar
      end
    end
  end

  def self.hash_dot_hash(h1, h2)
    h1.inject(0.0) do |sum, (key, _)|
      if h2.has_key?(key)
        sum + h1[key] * h2[key]
      else
        sum
      end
    end
  end

end

