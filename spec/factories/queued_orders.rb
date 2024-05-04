FactoryBot.define do
  factory :queued_order do
    order
    event_queue
    status { "MyString" }
  end
end
