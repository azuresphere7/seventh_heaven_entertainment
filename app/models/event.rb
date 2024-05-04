class Event < ApplicationRecord
  has_rich_text :description

  validates :title, presence: true
  validates :price, presence: true
  validates :location, presence: true
  validates :starts_on, presence: true
  validates :ends_on, presence: true
  validate :starts_on_in_future
  validate :ends_on_after_starts_on

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
