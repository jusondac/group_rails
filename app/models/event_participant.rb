class EventParticipant < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :user_id, uniqueness: { scope: :event_id, message: "is already registered for this event" }
  validates :status, inclusion: { in: %w[attending maybe declined] }

  # Scopes
  scope :attending, -> { where(status: "attending") }
  scope :maybe, -> { where(status: "maybe") }
  scope :declined, -> { where(status: "declined") }
end
