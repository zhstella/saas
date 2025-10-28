FactoryBot.define do
  factory :comment do
    association :post
    association :user
    body { "Insightful response" }
  end
end
