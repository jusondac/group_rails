class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :community
  has_many :payments, dependent: :destroy

  validates :user_id, uniqueness: { scope: :community_id, message: "is already a member of this community" }
  validates :role, inclusion: { in: %w[admin member] }
  validates :status, inclusion: { in: %w[pending approved rejected] }

  # Scopes
  scope :admins, -> { where(role: "admin") }
  scope :members, -> { where(role: "member") }
  scope :approved, -> { where(status: "approved") }
  scope :pending, -> { where(status: "pending") }

  # Check if member is an admin
  def admin?
    role == "admin"
  end

  # Check if membership is approved
  def approved?
    status == "approved"
  end

  # Check if membership is pending
  def pending?
    status == "pending"
  end

  # Get pending payments
  def pending_payments
    payments.pending
  end

  # Check if there are any overdue payments
  def has_overdue_payments?
    payments.overdue.exists?
  end

  # Generate next payment
  def generate_payment
    return unless approved?
    return unless community.has_finance_enabled?
    return if payments.pending.or(payments.paid).exists?

    finance = community.finance_setting
    due_date = finance.next_due_date
    period = finance.period_name

    payments.create(
      amount: finance.amount,
      due_date: due_date,
      period: period
    )
  end
end
