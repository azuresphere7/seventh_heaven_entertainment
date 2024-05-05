class TicketReservation < ApplicationRecord
  DURATION = 8.minutes
  RESERVATION_STATUSES = [
    ENQUEUED = "enqueued",
    EXPIRED = "expired",
    NO_AVAILABILITY = "no_availability",
    CANCELLED = "cancelled",
    ACTIVE = "active"
  ].freeze
  belongs_to :ticket_sale

  # TODO: constants for statuses
  validates :status, presence: true, inclusion: {in: RESERVATION_STATUSES}
  validates :quantity, presence: true, numericality: {greater_than: 0, less_than: 7}

  scope :enqueued, -> { where(status: :enqueued) }
  scope :active, -> { where(status: :active) }

  delegate :event_id, to: :ticket_sale

  def self.add(quantity:, reservation_number:)
    create!(
      quantity: quantity,
      reservation_number: reservation_number,
      status: :enqueued
    )
  end

  def self.head_of_the_queue
    order(created_at: :asc).first
  end

  # TODO: test
  def activate
    update!(status: ACTIVE, valid_until: DURATION.from_now)
    ExpireTicketReservationJob.set(wait_until: valid_until).perform_later(reservation_number)
  end

  def cancel_because_of_no_availability
    update!(status: :no_availability)
  end

  def expire
    update!(status: :expired)
  end

  def can_expire?
    active? && valid_until < Time.current
  end

  def active?
    status == ACTIVE
  end
end
