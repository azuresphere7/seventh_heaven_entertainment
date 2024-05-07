class TicketSale < ApplicationRecord
  class InvalidReservation < StandardError; end

  class Queue
    attr_reader :sale, :reservations
    private :sale, :reservations

    def initialize(sale)
      @sale = sale
      @reservations = sale.enqueued_reservations
    end

    def process
      return if reservations.empty?

      reservations.find_each do |reservation|
        if can_activate_reservation?(reservation)
          reservation.activate
        elsif needs_to_await_active_reservations?(reservation)
          break
        elsif no_availability?(reservation)
          reservation.cancel_because_of_no_availability
          next if sale.tickets_available?
        else
          # :nocov: there is no way to reach this code path
          raise "Unknown reservation state for #{reservation.reservation_number}"
          # :nocov:
        end
      end
    rescue
      debugger
    end

    def reservation_at_head_of_the_queue?(reservation_number:)
      reservations.head_of_the_queue.reservation_number == reservation_number
    end

    private

    def can_activate_reservation?(reservation)
      reservation.quantity <= sale.number_of_available_tickets
    end

    def needs_to_await_active_reservations?(reservation)
      reservation.quantity <= sale.number_of_unsold_tickets
    end

    def no_availability?(reservation)
      reservation.quantity > sale.number_of_unsold_tickets
    end
  end

  belongs_to :event
  has_many :ticket_reservations, dependent: :destroy
  delegate :capacity, :price, to: :event

  def process_queue
    queue.process
  end

  def queue_reservation(reservation_number:, quantity:)
    ticket_reservations.add(
      quantity: quantity,
      reservation_number: reservation_number
    )
  end

  # :reek:FeatureEnvy
  def expire_reservation(reservation_number:)
    reservation = find_reservation(reservation_number)
    reservation.expire if reservation.can_expire?
  end

  # TODO: add default payment status
  # # TODO: locking
  def submit_order(reservation_number:, customer_details:)
    reservation = find_reservation(reservation_number)
    raise InvalidReservation unless reservation.active?
    Order.submit(
      event_id: event.id,
      quantity: reservation.quantity,
      customer_details: customer_details
    )
    reservation.destroy!
  end

  def reservation_at_head_of_the_queue?(reservation_number:)
    queue.reservation_at_head_of_the_queue?(
      reservation_number: reservation_number
    )
  end

  def number_of_sold_tickets
    Order.for_event(event.id).sum(:quantity)
  end

  def number_of_reserved_tickets
    ticket_reservations.active.sum(:quantity)
  end

  def number_of_available_tickets
    capacity - (number_of_reserved_tickets + number_of_sold_tickets)
  end

  def number_of_unsold_tickets
    capacity - number_of_sold_tickets
  end

  def enqueued_reservations
    ticket_reservations.enqueued.order(created_at: :asc)
  end

  def tickets_available?
    number_of_available_tickets > 0
  end

  private

  def queue
    Queue.new(self)
  end

  # :reek:UtilityFunction
  def find_reservation(reservation_number)
    TicketReservation.find_by!(reservation_number: reservation_number)
  end
end
