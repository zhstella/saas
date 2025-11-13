FactoryBot.define do
  factory :post do
    association :user
    association :topic
    title { "Sample Post" }
    body { "This is a sample post body." }
    expires_at { nil }
    status { 'open' }
    school { Post::SCHOOLS.first }
    course_code { 'COMS W4152' }

    after(:build) do |post|
      next unless post.tags.empty?

      tag = Tag.first || create(:tag)
      post.tags << tag
    end

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
