# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
if Hero.count == 0
  Hero.create(name: 'Priest')
  Hero.create(name: 'Rogue')
  Hero.create(name: 'Mage')
  Hero.create(name: 'Paladin')
  Hero.create(name: 'Warrior')
  Hero.create(name: 'Warlock')
  Hero.create(name: 'Hunter')
  Hero.create(name: 'Shaman')
  Hero.create(name: 'Druid')
end

def attributes_by_json_card(card)
  {
    ref: card[:id],
    name: card[:name],
    description: card[:description],
    mana: card[:mana],
    type: card[:type],
    hero: card[:class],
    set: card[:set],
    quality: card[:legendary],
    race: card[:race],
    attack: card[:attack],
    health: card[:health]
  }
end

cards = JSON.parse(File.read(File.join(Rails.root, 'db', 'cards.json')), symbolize_names: true)
p "Updating cards"
p Card.count
cards.each do |card|
  db_card = Card.where(ref: card[:id]).first_or_initialize
  db_card.update_attributes(ref: card[:id],
                            name: card[:name],
                            description: card[:description],
                            mana: card[:mana],
                            type: card[:type],
                            hero: card[:class],
                            set: card[:set],
                            quality: card[:legendary],
                            race: card[:race],
                            attack: card[:attack],
                            health: card[:health])
end
p Card.count

if Rails.env.development? && User.count == 0
  user = User.create(username: 'lolo', password: '123456', password_confirmation: '123456')

  100.times do |x|
    Result.create(mode: [:arena, :casual, :practice, :ranked].sample,
                  hero: Hero.all.sample,
                  opponent: Hero.all.sample,
                  win: [true, false].sample,
                  coin: [true, false].sample,
                  user: user,
                 )
  end
end

