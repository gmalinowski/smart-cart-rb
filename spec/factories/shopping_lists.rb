FactoryBot.define do
  factory :shopping_list do
    name { Faker::Lorem.word }
    note { Faker::Lorem.sentence }
    association :owner, factory: :user
  end
end
