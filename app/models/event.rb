class Event < ApplicationRecord
  has_rich_text :description
  has_many :orders, dependent: :destroy
  has_one :ticket_sale, dependent: :destroy

  validates :title, presence: true
  validates :price, presence: true, numericality: {greater_or_equal_than: 0} # We do free events too!
  validates :location, presence: true
  validates :starts_on, presence: true
  validates :ends_on, presence: true
  validates :ticket_sale, presence: true
  validates :capacity, presence: true, numericality: {greater_than: 0}
  validate :starts_on_in_future
  validate :ends_on_after_starts_on

  scope :with_open_ticket_sale, -> { where("starts_on > ?", Time.current) }

  # ideally the creation of a ticket sale handled async,
  # near realtime after creation, or by a specified moment in the future
  # after which an event is marked as 'published'
  after_initialize { build_ticket_sale(capacity: capacity) unless ticket_sale }

  def published?
    persisted? # for now the default
  end

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
