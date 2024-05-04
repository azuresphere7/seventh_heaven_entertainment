class Event < ApplicationRecord
  has_rich_text :description
  has_many :orders, dependent: :destroy
  has_one :event_queue, dependent: :destroy

  validates :title, presence: true
  validates :price, presence: true
  validates :location, presence: true
  validates :starts_on, presence: true
  validates :ends_on, presence: true
  validates :event_queue, presence: true
  validates :amount_of_tickets, presence: true, numericality: {greater_than: 0}
  validate :starts_on_in_future
  validate :ends_on_after_starts_on

  after_initialize { build_event_queue unless event_queue }

  private

  def starts_on_in_future
    return unless starts_on.present? && starts_on < Time.zone.now

    errors.add(:starts_on, "must be in the future")
  end

  def ends_on_after_starts_on
    return unless starts_on.present? && ends_on.present? && ends_on < starts_on

    errors.add(:ends_on, "must be after the starts_on date")
  end
end
