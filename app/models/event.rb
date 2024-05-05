class Event < ApplicationRecord
  has_rich_text :description
  has_many :orders, dependent: :destroy
  has_one :ticket_sale, dependent: :destroy

  validates :title, presence: true
  validates :price, presence: true
  validates :location, presence: true
  validates :starts_on, presence: true
  validates :ends_on, presence: true
  validates :ticket_sale, presence: true
  validates :capacity, presence: true, numericality: {greater_than: 0}
  validate :starts_on_in_future
  validate :ends_on_after_starts_on

  after_initialize { build_ticket_sale unless ticket_sale }

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
