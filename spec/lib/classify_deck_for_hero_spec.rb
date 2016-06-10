require 'spec_helper'

describe ClassifyDeckForHero do

  let(:shaman) { Hero.find_by_name('Shaman') }

  let(:midrange) { Deck.find_by!(key: 'midrange', hero: shaman) }
  let(:aggro) { Deck.find_by!(key: 'aggro', hero: shaman) }

  let(:input) do
    {
      'Lava Burst' => 1,
      'Totem Golem' => 2,
      'Lightning Bolt' => 2,
      'Flametongue Totem' => 2,
      'Tunnel Trogg' => 1,
      'Rockbiter Weapon' => 2,
    }
  end

  let(:classifiers) { Hash.new }

  subject { described_class.new(shaman, input) }

  before do
    subject.eligible_decks.each do |deck|
      classifiers[deck.key] = double('classifier').tap do |clf|
        allow(deck).to receive(:classifier).and_return(clf)
        allow(clf).to receive(:predict_score).and_return(0.0)
      end
    end
  end

  describe '#predict' do
    it 'uses a normalized card count (so the total cards amounts to 30)' do
      expect(classifiers['aggro']).to receive(:predict_score).with({
        'Lava Burst' => 3,
        'Totem Golem' => 6,
        'Lightning Bolt' => 6,
        'Flametongue Totem' => 6,
        'Tunnel Trogg' => 3,
        'Rockbiter Weapon' => 6,
      })
      subject.predict
    end

    it 'returns the best scoring deck for the hero' do
      expect(classifiers['aggro']).to receive(:predict_score).and_return(1.1)
      expect(classifiers['midrange']).to receive(:predict_score).and_return(1.9)
      expect(subject.predict).to eq midrange
    end

    it 'returns nil when unertain (score < 1)' do
      expect(classifiers['aggro']).to receive(:predict_score).and_return(0.4)
      expect(classifiers['midrange']).to receive(:predict_score).and_return(0.7)
      expect(subject.predict).to eq nil
    end

    context 'not enough cards' do
      let(:input) do
        {
          'Lava Burst' => 1,
          'Totem Golem' => 2,
        }
      end

      specify { expect(subject.predict).to eq nil }

      it 'does not classify' do
        expect(classifiers['aggro']).not_to receive(:predict_score)
        subject.predict
      end
    end

  end

  describe '#learn' do
    it 'learns the true deck' do
      expect(classifiers['midrange']).to receive(:train).with(anything, -1)
      expect(classifiers['aggro']).to receive(:train).with(anything, 1)
      expect_any_instance_of(Deck).to receive(:save!)
      subject.learn! aggro
    end

    it 'accepts nil' do
      expect(classifiers['midrange']).to receive(:train).with(anything, -1)
      expect(classifiers['aggro']).to receive(:train).with(anything, -1)
      expect_any_instance_of(Deck).to receive(:save!)
      subject.learn! nil
    end

    context 'not enough cards supplied' do
      let(:input) do
        {
          'Lava Burst' => 1,
          'Totem Golem' => 2,
          'Lightning Bolt' => 2
        }
      end

      it 'does not learn' do
        expect_any_instance_of(Deck).not_to receive(:save!)
        subject.learn! aggro
      end
    end

  end

end
