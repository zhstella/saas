FactoryBot.define do
  factory :post do
    association :user
    title { "Sample Post" }
    body { "This is a sample post body." }
  end
end
