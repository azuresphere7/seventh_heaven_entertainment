class CustomerInfo < ApplicationRecord
  belongs_to :order

  GENDERS = [
    MALE = "male",
    FEMALE = "female",
    OTHER = "other",
    PREFER_NOT_TO_SAY = "prefer_not_to_say"
  ]

  validates :name, presence: true
  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :gender, presence: true, inclusion: {in: GENDERS, allow_blank: true}
  validates :age, presence: true, numericality: {greater_than: 0, less_than: 150}, allow_blank: false
end
