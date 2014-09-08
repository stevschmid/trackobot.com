FactoryGirl.define do
  factory :result do
    hero
    opponent factory: :hero
    win true
    coin true
    mode :ranked
    user
    duration 42
  end
end
