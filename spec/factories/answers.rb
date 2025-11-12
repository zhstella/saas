FactoryBot.define do
  factory :answer do
    association :post
    association :user
    body { "Insightful response" }
  end
end
