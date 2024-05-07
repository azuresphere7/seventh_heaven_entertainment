FactoryBot.define do
  factory :ticket_sale do
    event
    capacity { 1 }
    number_of_sold_tickets { 0 }
    number_of_reserved_tickets { 0 }
  end
end
