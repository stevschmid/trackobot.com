FactoryGirl.define do
  factory :card_history do
    result
    player 0
    card factory: :card
  end
end
