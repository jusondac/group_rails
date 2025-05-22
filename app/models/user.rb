class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :communities, through: :memberships
  has_many :event_participants, dependent: :destroy
  has_many :events, through: :event_participants

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Get all communities where the user is an admin
  def admin_of
    communities.joins(:memberships).where(memberships: { user_id: id, role: "admin" })
  end

  # Get all communities where the user is a member with approved status
  def member_of
    communities.joins(:memberships).where(memberships: { user_id: id, role: "member", status: "approved" })
  end

  # Get all pending membership requests
  def pending_memberships
    memberships.where(status: "pending")
  end

  # Check if user is admin of a specific community
  def admin_of?(community)
    memberships.exists?(community: community, role: "admin")
  end

  # Check if user is a member of a specific community
  def member_of?(community)
    memberships.exists?(community: community, status: "approved")
  end
end
