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
  validates :quantity, numericality: {greater_than: 0, less_than: 7}
  validates :reference, presence: true

  with_options on: [:activate, :cancel_because_of_no_availability] do
    validate :validate_was_enqueued
  end

  with_options on: :expire do
    validate :validate_was_active
  end

  with_options on: :activate do
    validates :valid_until, presence: true
  end

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

  def activate
    assign_attributes(status: ACTIVE, valid_until: DURATION.from_now)
    save!(context: :activate)

    # Ideally i would not like to have any ActiveJob calls in the models
    # I would like to have a more event driven approach
    # by implementing events and handle each "after action" async with rails event store
    AfterActivatingReservationJob.perform_later(reference)
  end

  def cancel_because_of_no_availability
    assign_attributes(status: NO_AVAILABILITY)
    save!(context: :cancel_because_of_no_availability)
  end

  def expire
    assign_attributes(status: EXPIRED)
    save!(context: :expire)

    AfterExpiringReservationJob.perform_later(reference)
  end

  def self.head_of_the_queue
    enqueued.order(created_at: :asc).first
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

  def to_param
    reference
  end

  private

  def status_was_enqueued?
    status_was == ENQUEUED
  end

  def status_was_active?
    status_was == ACTIVE
  end

  def validate_was_enqueued
    errors.add(:status, "was not enqueued, status: #{status_was}") unless status_was_enqueued?
  end

  def validate_was_active
    errors.add(:status, "was not active, status: #{status_was}") unless status_was_active?
  end
end
