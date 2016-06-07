FactoryGirl.define do
  factory :deck do
    name "deck-#{SecureRandom.hex}"
    hero
  end
end
