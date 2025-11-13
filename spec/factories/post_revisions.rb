FactoryBot.define do
  factory :post_revision do
    association :post
    association :user
    title { "Original Title" }
    body { "Original body content" }
  end
end
