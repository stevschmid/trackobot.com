# rake db:seed update_decks=true
if Deck.count == 0 || ENV['update_decks']
  Deck.count.tap do |count_before|
    Deck.update_all(active: false)

    decks_by_hero = JSON.parse(File.read(File.join(Rails.root, 'db', 'decks.json')), symbolize_names: true)
    decks_by_hero.each do |hero_name, decks|
      decks.each do |deck|
        db_deck = Deck.where(key: deck[:key], hero: hero_name.downcase).first_or_initialize
        db_deck.update_attributes(name: deck[:name], active: true)
      end
    end

    puts "Decks added: #{Deck.count - count_before}"
  end
end

if Rails.env.development? && User.count == 0
  user = User.create(username: 'dev', password: 'dev')
  players = [:me, :opponent]
  all_cards = CARDS.values
  all_heroes = Hero::MAPPING.values

  generate_match = -> (turns, attributes) {
    result = Result.new(attributes)
    result.rank = rand(1..25) if result.ranked? && !result.rank
    result.build_card_history(data: turns.times.map do |n|
      {
        player: players[(n + (result.coin ? 1 : 0)) % 2],
        card_id: all_cards.sample[:id],
        turn: n + 1
      }
    end)
    result.save!
    result
  }

  100.times do
    generate_match.(
      rand(2..10),
      mode: [:casual, :practice, :ranked].sample,
      hero: all_heroes.sample,
      opponent: all_heroes.sample,
      win: [true, false].sample,
      coin: [true, false].sample,
      user: user,
      created_at: Date.today - rand(0..40).days,
    )
  end

  # Generate realistic-looking Arena runs
  days = (1..40).to_a
  30.times do
    hero = all_heroes.sample
    total_wins = rand(0..12)
    total_losses = total_wins == 12 ? rand(0..2) : 3
    total_matches = total_wins + total_losses
    start_date = Date.today - days.delete(days.sample).days

    wins = losses = 0
    total_matches.times do |i|
      total_turns = rand(2..10)
      won = [true, false].sample
      won = false if wins == total_wins
      # Unless this is a 12-0 run, ensure that the final match is a loss:
      won = true if total_losses == 3 && losses == 2 && i < total_matches-1

      won ? (wins+=1) : (losses+=1)
      start_date += total_turns.minutes

      generate_match.(
        total_turns,
        mode: :arena,
        hero: hero,
        opponent: all_heroes.sample,
        win: won,
        coin: [true, false].sample,
        user: user,
        created_at: start_date,
      )
    end
  end
end
