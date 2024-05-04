class QueuedOrder < ApplicationRecord
  belongs_to :order
  belongs_to :event_queue
end
