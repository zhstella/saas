FactoryBot.define do
  factory :answer_comment do
    association :answer
    association :user
    body { "Appreciate this insight" }
  end
end
