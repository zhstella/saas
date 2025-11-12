FactoryBot.define do
  factory :thread_identity do
    association :user
    association :post
    pseudonym { "Lion ##{SecureRandom.alphanumeric(4).upcase}" }
  end
end
