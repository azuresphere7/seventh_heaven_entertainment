FactoryBot.define do
  factory :ticket_reservation do
    ticket_sale
    quantity { 1 }
    status { "enqueued" }
    reference { SecureRandom.uuid }
  end
end
