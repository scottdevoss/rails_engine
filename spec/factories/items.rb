FactoryBot.define do
  factory :item do
    association :merchant
    name { Faker::Hipster.word }
    description { Faker::Hipster.sentence }
    unit_price { Faker::Number.number(digits: 2) }
  end
end
