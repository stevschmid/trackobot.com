require 'spec_helper'

describe AdaGradClassifier do
  describe '::compute_gradient' do
    subject { instance }

    describe 'hinge loss gradient' do
      let(:gradient) { described_class.compute_gradient(x, y, w) }

      context 'when classification ok (no loss)' do
        let(:w) { HashWithIndifferentAccess[a: 0.0, b: 1.0] }
        let(:x) { HashWithIndifferentAccess[b: 1.0, a: 1.0] }
        let(:y) { 1 }

        specify { expect(gradient).to eq HashWithIndifferentAccess[a: 0.0, b: 0.0] }
      end

      context 'when classification not ok (loss)' do
        let(:w) { HashWithIndifferentAccess[a: 0.0, b: -1.0] }
        let(:x) { HashWithIndifferentAccess[b: 1.0, a: 0.5] }
        let(:y) { 2 }

        specify { expect(gradient).to eq HashWithIndifferentAccess[a: -1.0, b: -2.0] }
      end
    end
  end

  let(:instance) { described_class.new(master_learn_rate: 1.0) }

  describe '#train' do
    subject { -> { instance.train(x, y) } }

    let(:x) { HashWithIndifferentAccess[a: 0.5, b: 2.0] }
    let(:y) { 1 }

    it 'updates the sum of squares' do
      subject.call
      expect(instance.sum_of_squared_gradients[:a]).to be_within(0.00001).of(0.25)
      expect(instance.sum_of_squared_gradients[:b]).to be_within(0.00001).of(4.0)
    end

    it 'updates the weights' do
      # w[0] = 0.0 - 1.0 / sqrt(0.25) * -0.5 = 1.0
      # w[1] = 0.0 - 1.0 / sqrt(4.0) * -2.0 = 1.0
      subject.call
      expect(instance.weights[:a]).to be_within(0.00001).of(1.0)
      expect(instance.weights[:b]).to be_within(0.00001).of(1.0)
    end

    describe 'two fits' do
      let(:x2) { HashWithIndifferentAccess[b: -1.0, a: 0.5] } # second dim is informative
      let(:y2) { -1 }

      it 'updates the weights' do
        instance.train(x, y)
        instance.train(x2, y2)

        # t1
        # gradient = [-0.5, -2.0]
        # w[0] = 0.0 - 1.0 / sqrt(0.25) * -0.5 = 1.0
        # w[1] = 0.0 - 1.0 / sqrt(4.0) * -2.0 = 1.0

        # t2
        # gradient = [-0.5, 1.0]
        # w[0] = 1.0 - 1.0 / sqrt(0.5) * 0.5 = 0.29
        # w[1] = 1.0 - 1.0 / sqrt(5.0) * -1.0 = 1.44
        expect(instance.weights[:a]).to be_within(0.01).of(0.29)
        expect(instance.weights[:b]).to be_within(0.01).of(1.44)
      end

      context 'different feature sizes' do
        before do
          x2[:z] = 0.5
        end

        it 'works' do
          instance.train(x, y)
          instance.train(x2, y2)
          expect(instance.weights[:z]).to be_within(0.00001).of(-1.0)
        end
      end
    end

  end
end
