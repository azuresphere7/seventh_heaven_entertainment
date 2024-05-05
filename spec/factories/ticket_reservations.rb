FactoryBot.define do
  factory :ticket_reservation do
    ticket_sale
    quantity { 1 }
    status { "enqueued" }
    reservation_number { SecureRandom.uuid }
  end
end
