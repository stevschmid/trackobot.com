FactoryBot.define do
  factory :result do
    hero { 'priest' }
    opponent { 'warrior' }
    win { true }
    coin { true }
    mode { :ranked }
    user
    duration { 42 }

    factory :result_with_arena do
      mode { :arena }
      before(:create) { |result, _| AssignArenaToResult.call(result: result) }
    end
  end
end
