
FactoryBot.define do
  factory :invitation_link do
    association :user_id, factory: :user
  end
end
