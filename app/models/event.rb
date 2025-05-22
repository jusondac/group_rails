class Event < ApplicationRecord
  belongs_to :community
  belongs_to :created_by, class_name: "User"
  has_many :event_participants, dependent: :destroy
  has_many :users, through: :event_participants

  validates :name, presence: true
  validates :start_date, presence: true

  # Scopes
  scope :upcoming, -> { where("start_date > ?", Time.current).order(start_date: :asc) }
  scope :past, -> { where("start_date <= ?", Time.current).order(start_date: :desc) }
  scope :public_events, -> { where(private: false) }

  # Check if a user can join this event
  def can_join?(user)
    return true unless private?
    return true if community.users.include?(user)
    false
  end

  # Get all attending participants
  def attendees
    users.joins(:event_participants).where(event_participants: { event_id: id, status: "attending" })
  end

  # Humanized time range
  def time_range
    if start_date.to_date == end_date&.to_date
      "#{start_date.strftime('%b %d, %Y, %l:%M %p')} - #{end_date.strftime('%l:%M %p')}"
    elsif end_date.present?
      "#{start_date.strftime('%b %d, %Y, %l:%M %p')} - #{end_date.strftime('%b %d, %Y, %l:%M %p')}"
    else
      start_date.strftime("%b %d, %Y, %l:%M %p")
    end
  end
end
