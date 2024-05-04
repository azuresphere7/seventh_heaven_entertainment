module OrderService
  def self.create(params)
    Order.create!(params).tap do |order|
      event_queue = EventQueue.find_by(event_id: order.event_id)
      event_queue.add_order(order)
    end
  end

  # def self.confirm(params)
  # end
end
