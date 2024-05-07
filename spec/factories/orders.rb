FactoryBot.define do
  factory :order do
    quantity { 1 }
    ticket_price { "9.99" }
    event
  end
end
