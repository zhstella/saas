FactoryBot.define do
  factory :post do
    association :user
    title { "Sample Post" }
    body { "This is a sample post body." }
    expires_at { nil }

    trait :expiring_soon do
      expires_at { 10.days.from_now }
    end

    trait :expired do
      expires_at { 10.days.from_now }

      after(:create) do |post|
        post.update_column(:expires_at, 2.days.ago)
      end
    end
  end
end
