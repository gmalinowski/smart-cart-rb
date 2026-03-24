
FactoryBot.define do
  factory :group do
    name { Faker::Lorem.word }
    association :owner, factory: :user
  end
end
