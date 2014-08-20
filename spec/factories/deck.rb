FactoryGirl.define do
  factory :deck do
    name "deck-#{SecureRandom.hex}"
    user
  end
end
