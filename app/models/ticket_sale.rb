class TicketSale < ApplicationRecord
  class InvalidReservation < StandardError; end

  belongs_to :event
  has_many :ticket_reservations, dependent: :destroy
  validates :capacity, presence: true, numericality: {greater_than: 0}
  delegate :price, to: :event

  def queue_reservation(reference:, quantity:)
    ticket_reservations.enqueue(
      quantity: quantity,
      reference: reference
    )
  end

  def process_queue
    ticket_reservations.enqueued.find_each do |reservation|
      break if awaiting_active_reservations?(reservation)

      process_enqueued_reservation(reservation)
    end
  end

  def process_enqueued_reservation(reservation)
    with_lock do
      reservation = find_reservation(reservation.reference)
      if requested_tickets_available?(reservation)
        reservation.activate
        add_to_reserved_tickets(reservation.quantity)
      elsif requested_tickets_not_available?(reservation)
        reservation.cancel_because_of_no_availability
      else
        # :nocov: there is no way to reach this reference path
        raise "Unknown reservation state for #{reservation.reference}"
        # :nocov:
      end
    end
  end

  # :reek:FeatureEnvy
  def expire_reservation(reference:)
    with_lock do
      reservation = find_reservation(reference)

      if reservation.can_expire?
        reservation.expire
        remove_from_reserved_tickets(reservation.quantity)
      end
    end
  rescue ActiveRecord::RecordNotFound
    # it can silently fail here, as the reservation is already expired
  end

  def requested_tickets_available?(reservation)
    reservation.quantity <= number_of_available_tickets
  end

  def awaiting_active_reservations?(reservation)
    number_of_available_tickets < reservation.quantity && reservation.quantity <= number_of_unsold_tickets
  end

  def requested_tickets_not_available?(reservation)
    reservation.quantity > number_of_unsold_tickets
  end

  def submit_order(reference:, customer_details:)
    with_lock do
      reservation = find_reservation(reference)

      if reservation.active?
        Order.submit(
          event_id: event.id,
          quantity: reservation.quantity,
          ticket_price: price,
          reference: reference,
          customer_details: customer_details
        )
        reservation.destroy!
        add_to_sold_and_removed_from_reserved_tickets(reservation.quantity)
      else

        raise InvalidReservation
      end
    end
  end

  def reservation_at_head_of_the_queue?(reference:)
    ticket_reservations.head_of_the_queue.reference == reference
  end

  private

  def number_of_available_tickets
    capacity - (number_of_reserved_tickets + number_of_sold_tickets)
  end

  def number_of_unsold_tickets
    capacity - number_of_sold_tickets
  end

  def add_to_reserved_tickets(quantity)
    update!(number_of_reserved_tickets: number_of_reserved_tickets + quantity)
  end

  def remove_from_reserved_tickets(quantity)
    update!(number_of_reserved_tickets: number_of_reserved_tickets - quantity)
  end

  def add_to_sold_and_removed_from_reserved_tickets(quantity)
    update!(
      number_of_sold_tickets: number_of_sold_tickets + quantity,
      number_of_reserved_tickets: number_of_reserved_tickets - quantity
    )
  end

  # :reek:UtilityFunction
  def find_reservation(reference)
    TicketReservation.find_by!(reference: reference)
  end
end
