FactoryBot.define do
  factory :event do
    title { "MyString" }
    price { "9.99" }
    starts_on { Time.zone.tomorrow }
    ends_on { Time.zone.tomorrow + 1.day }
    description { "MyText" }
    location { "MyLocation" }
    capacity { 1 }
  end
end
