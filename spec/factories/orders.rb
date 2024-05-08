FactoryBot.define do
  factory :order do
    event
    quantity { 1 }
    ticket_price { "9.99" }
    reference { SecureRandom.uuid }
  end
end
