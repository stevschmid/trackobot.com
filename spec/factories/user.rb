FactoryGirl.define do
  factory :user do
    username 'test'
    password 'password'
    password_confirmation { 'password' }
  end
end
