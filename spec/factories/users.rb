FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    password_confirmation { password }
    confirmed_at { Time.zone.now }
  end

  factory :unconfirmed_user, parent: :user do
    confirmed_at { nil }
  end
end
