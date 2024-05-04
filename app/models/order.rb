class Order < ApplicationRecord
  belongs_to :event

  validates :quantity, presence: true, numericality: {greater_than: 0, less_than: 7}
end
