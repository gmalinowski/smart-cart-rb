
FactoryBot.define do
  factory :invitation_link do
    association :user_id, factory: :user
    expires_at { 30.day.from_now }
  end
end
