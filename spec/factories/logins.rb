FactoryGirl.define do
  factory :login do
    email { Faker::Internet.email }

    trait :password do
      password { Faker::Lorem.word }
    end

    trait :facebook do
      password { Faker::Number.number }
    end

    trait :verified do
      verified_at { Time.zone.now }
    end
  end
end
