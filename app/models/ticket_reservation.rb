class TicketReservation < ApplicationRecord
  DURATION = 8.minutes
  RESERVATION_STATUSES = [
    ENQUEUED = "enqueued",
    EXPIRED = "expired",
    NO_AVAILABILITY = "no_availability",
    ACTIVE = "active"
  ].freeze
  belongs_to :ticket_sale

  validates :status, presence: true, inclusion: {in: RESERVATION_STATUSES}
  validates :quantity, presence: true, numericality: {greater_than: 0, less_than: 7}

  scope :enqueued, -> { where(status: :enqueued) }
  scope :active, -> { where(status: :active) }

  delegate :event_id, to: :ticket_sale

  def self.enqueue(quantity:, reference:)
    create!(
      quantity: quantity,
      reference: reference,
      status: :enqueued
    )
  end

  def self.head_of_the_queue
    order(created_at: :asc).first
  end

  def to_param
    reference
  end

  def activate
    update!(status: ACTIVE, valid_until: DURATION.from_now)
    ExpireTicketReservationJob.set(wait_until: valid_until).perform_later(reference)

    # near realtime performance is good enough,
    # ideally i would factor out these jobs in active record models
    # by implementing events and handles with rails event store
    AfterActivatingReservationJob.perform_later(reference)
  end

  def cancel_because_of_no_availability
    update!(status: :no_availability)
  end

  def expire
    update!(status: EXPIRED)
  end

  def can_expire?
    active? && valid_until < Time.current
  end

  def active?
    status == ACTIVE
  end

  def enqueued?
    status == ENQUEUED
  end

  def ticket_price
    ticket_sale.price
  end

  def total_price
    quantity * ticket_price
  end
end
