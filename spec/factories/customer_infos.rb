FactoryBot.define do
  factory :customer_info do
    order
    name { "John Doe" }
    email { "john.doe@gmail.com" }
    age { 18 }
    gender { "male" }
  end
end
