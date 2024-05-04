class EventQueue < ApplicationRecord
  belongs_to :event
  has_many :queued_orders, dependent: :destroy
  default_scope { includes(:queued_orders).order("queued_orders.created_at ASC") }
  delegate :amount_of_tickets, to: :event

  def add_order(order)
    # if order.quantity < available_tickets
    #   order.reserved!
    # else
    #   order.waitlist!
    # end

    queued_orders.create(order: order)

    # if first queued order, process order
  end

  # def process_order(order)
  # if there are enough tickets, set order to serve
  # else, let the user know
  # process next order
  # end

  # def remove_order_from_queue(order)
  # end

  # def reserved_tickets
  #   queued_orders.reserved.sum(:quantity)
  # end

  # def available_tickets
  #   amount_of_tickets - reserved_tickets
  # end
end
