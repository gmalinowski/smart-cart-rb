
FactoryBot.define do
  factory :friendship do
    association :user, factory: :user
    association :friend, factory: :user
  end
end
