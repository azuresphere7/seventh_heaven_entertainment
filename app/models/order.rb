class Order < ApplicationRecord
  belongs_to :event

  scope :for_event, ->(event_id) { where(event_id: event_id) }
  has_one :customer_info, dependent: :destroy
  accepts_nested_attributes_for :customer_info
  validates_associated :customer_info

  delegate :name, :email, :gender, :age, to: :customer_info,
    prefix: :customer, allow_nil: true

  def self.submit(event_id:, quantity:, customer_details:)
    order = new(event_id: event_id, quantity: quantity)
    order.build_customer_info(customer_details)
    order.save!
  end

  def total
    quantity * ticket_price
  end
end
