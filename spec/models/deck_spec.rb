require 'spec_helper'

describe Deck do
  let(:user) { FactoryGirl.create(:user) }
  let(:mode) { :ranked }

  it 'has a valid factory' do
    expect(FactoryGirl.create(:deck)).to be_valid
  end

  def create_deck(hero_name, card_names)
    card_ids = Card.where(name: card_names).pluck(:id)
    FactoryGirl.create(:deck, hero: Hero.find_by_name(hero_name), user: user, card_ids: card_ids)
  end

  def create_result(as, vs, opts)
    FactoryGirl.build(:result, mode: mode, hero: Hero.find_by_name(as), opponent: Hero.find_by_name(vs), user: user).tap do |result|
      opts.each_pair do |player, card_names|
        Card.where(name: card_names).pluck(:id).each { |card_id| result.card_histories.new(card_id: card_id, player: player) }
      end
      result.save!
    end
  end

  describe 'result assignment' do
    let(:handlock_cards) { ['Ancient Watcher', 'Molten Giant', 'Mountain Giant', 'Twilight Drake'] }
    let(:zoolock_cards) { ['Abusive Sergeant', 'Doomguard', 'Flame Imp', 'Knife Juggler'] }
    let(:demonlock_cards) { ['Voidcaller', 'Doomguard', 'Molten Giant'] }
    let(:result) { create_result 'Warlock', 'Rogue',
                    me: ['Abusive Sergeant', 'Ancient Watcher', 'Doomguard', 'Doomguard', 'Mountain Giant', 'Twilight Drake'],
                    opponent: ['Southsea Deckhand', 'Ironbeak Owl', 'Sludge Belcher'] }

    let!(:handlock) { create_deck 'Warlock', handlock_cards }
    let!(:zoolock) { create_deck 'Warlock', zoolock_cards }
    let!(:demonlock) { create_deck 'Warlock', demonlock_cards }

    context 'after deck update' do
      it 'assigns the best matched deck (most cards matched) to all affected results' do
        result.update_attributes(deck_id: zoolock.id)
        zoolock.save
        expect(result.reload.deck_id).to eq(handlock.id)
      end

      describe 'number of same card should not matter' do
        let!(:result) { create_result 'Warlock', 'Rogue',
                        me: ['Ancient Watcher'] * 10 + ['Flame Imp', 'Knife Juggler'],
                        opponent: ['Southsea Deckhand', 'Ironbeak Owl', 'Sludge Belcher'] }

        it 'ignores the amount of the same card' do
          result.update_attributes(deck_id: demonlock.id)
          demonlock.save
          expect(result.reload.deck_id).to eq(zoolock.id)
        end
      end

      context 'arena games' do
        let(:mode) { :arena }

        it 'does NOT assign decks to arena results' do
          demonlock.save
          expect(result.reload.deck_id).to be_nil
        end
      end
    end

  end

end
