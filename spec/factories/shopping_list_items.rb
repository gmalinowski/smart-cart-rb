FactoryBot.define do
  factory :shopping_list_item do
    name { Faker::Lorem.word }
    association :shopping_list, factory: :shopping_list
  end
end
