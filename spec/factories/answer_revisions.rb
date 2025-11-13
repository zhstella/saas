FactoryBot.define do
  factory :answer_revision do
    association :answer
    association :user
    body { "Previous answer body" }
  end
end
