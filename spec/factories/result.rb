FactoryGirl.define do
  factory :result do
    hero
    opponent factory: :hero
    win true
    coin true
    mode :ranked
    user
  end
end
