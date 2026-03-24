FactoryBot.define do
  factory :group_shopping_list do
    association :group, factory: :group
    association :shopping_list, factory: :shopping_list
  end
end
