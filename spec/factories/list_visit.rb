FactoryBot.define do
  factory :list_visit do
    association :user, factory: :user
    association :shopping_list, factory: :shopping_list
    visited_at { Time.zone.now }
  end
end