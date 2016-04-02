require 'spec_helper'

describe Result do

  describe 'arena result' do
    let(:result) { FactoryGirl.create(:result, mode: :arena) }
    let(:arena) { result.arena }

    context 'result is the last remaining result of arena' do
      it 'deletes the arena' do
        expect { result.destroy }.to change { arena.destroyed? }
      end
    end

    context 'result is one among many results of arena' do
      before do
        2.times { FactoryGirl.create(:result, arena: arena) }
      end

      it 'does not delete the arena' do
        expect { result.destroy }.to_not change { arena.destroyed? }
      end
    end
  end

  describe 'card history list' do
    let(:first_play) { FactoryGirl.build(:card_history_entry, player: :me) }
    let(:second_play) { FactoryGirl.build(:card_history_entry, player: :opponent) }

    let(:result) { FactoryGirl.create(:result, mode: :ranked, card_history_list: [first_play, second_play]) }

    it 'has card_history_list in the right order' do
      expect(result.card_history_list.collect(&:player)).to eq [:me, :opponent]
    end
  end

  describe 'deck assignment' do
    def create_deck(hero_name, deck_name, card_names)
      card_ids = Card.where(name: card_names).pluck(:id)
      FactoryGirl.create(:deck, name: deck_name, hero: Hero.find_by_name(hero_name), user: user, card_ids: card_ids)
    end

    def build_result(as, vs, opts)
      FactoryGirl.build(:result, mode: mode, hero: Hero.find_by_name(as), opponent: Hero.find_by_name(vs), user: user).tap do |result|
        list = []
        opts.each_pair do |player, card_names|
          Card.where(name: card_names).each do |card|
            list << CardHistoryEntry.new(turn: 1, player: player, card: card)
          end
        end
        result.card_history_list = list
      end
    end

    let(:user) { FactoryGirl.create(:user) }

    let(:mode) { :ranked }
    let(:handlock_cards) { ['Ancient Watcher', 'Molten Giant', 'Mountain Giant', 'Twilight Drake'] }
    let(:zoolock_cards) { ['Abusive Sergeant', 'Doomguard', 'Flame Imp', 'Knife Juggler'] }
    let(:demonlock_cards) { ['Voidcaller', 'Doomguard', 'Molten Giant'] }

    let(:player_cards_played) { ['Abusive Sergeant', 'Ancient Watcher', 'Doomguard', 'Doomguard', 'Mountain Giant', 'Twilight Drake'] }
    let(:opponent_cards_played) { ['Southsea Deckhand', 'Ironbeak Owl', 'Sludge Belcher']  }

    let(:result) { build_result 'Warlock', 'Rogue', me: player_cards_played, opponent: opponent_cards_played }

    let!(:handlock) { create_deck 'Warlock', 'handlock', handlock_cards }
    let!(:zoolock) { create_deck 'Warlock', 'zoolock', zoolock_cards }
    let!(:demonlock) { create_deck 'Warlock', 'demonlock', demonlock_cards }

    it 'assigns the best matched deck (quotient-based) to all affected results' do
      # handlock: 3/4
      # zoolock: 2/4
      # demonlock: 1/3
      expect { result.save! }.to change { result.deck }.to handlock
    end

    it 'assigns only decks with the matching class' do
      handlock.update_attributes(hero_id: Hero.find_by_name('Rogue').id)
      expect { result.save! }.to change { result.deck }.to zoolock
    end

    it 'only looks at cards played by the player' do
      result = build_result 'Warlock', 'Warlock', me: ['Mountain Giant'], opponent: ['Abusive Sergeant']
      expect { result.save! }.to change { result.deck }.to handlock
    end

    context 'no card matches' do
      let(:result) { build_result 'Warlock', 'Rogue',
                      me: ['Azure Drake'],
                      opponent: [] }

      it 'does not assign any deck' do
        expect { result.save! }.to_not change { result.deck }
      end
    end

    context 'multiples of the same card' do
      let(:result) { build_result 'Rogue', 'Warlock',
                      me: [],
                      opponent: ['Voidcaller'] * 10 + ['Flame Imp', 'Knife Juggler'] }

      it 'ignores the amount of the same card' do
        expect { result.save! }.to change { result.opponent_deck }.to zoolock
      end
    end

    context 'arena games' do
      let(:mode) { :arena }

      it 'does NOT assign decks to arena results' do
        result.save!
        expect(result.reload.deck_id).to be_nil
      end
    end

    context 'when a deck has no cards' do
      before do
        handlock.update_attributes(cards: [])
      end

      it 'still works' do
        expect { result.save! }.to_not raise_error
      end
    end
  end

end
