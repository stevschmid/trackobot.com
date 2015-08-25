FactoryGirl.define do
  factory :card_history_entry do
    player :me
    card factory: :card
    turn 0
  end
end
