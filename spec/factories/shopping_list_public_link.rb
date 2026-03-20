
FactoryBot.define do
  factory :shopping_list_public_link do
    association :shopping_list, factory: :shopping_list
    association :created_by, factory: :user
  end
end
