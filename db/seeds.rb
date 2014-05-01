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

