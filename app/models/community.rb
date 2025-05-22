class Community < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :events, dependent: :destroy
  has_one :finance_setting, dependent: :destroy
  has_many :payments, through: :memberships

  validates :name, presence: true, uniqueness: true

  # Scopes
  scope :public_communities, -> { where(private: false) }

  # Methods
  def admin_users
    users.joins(:memberships).where(memberships: { community_id: id, role: "admin" })
  end

  def member_users
    users.joins(:memberships).where(memberships: { community_id: id, role: "member", status: "approved" })
  end

  def pending_users
    users.joins(:memberships).where(memberships: { community_id: id, status: "pending" })
  end

  # Get the creator of this community (the first admin)
  def creator
    memberships.where(role: "admin").order(created_at: :asc).first&.user
  end

  def public?
    !private
  end

  def upcoming_events
    events.upcoming
  end

  def past_events
    events.past
  end

  def has_finance_enabled?
    finance_setting&.active?
  end

  # Create or update the finance settings
  def update_finance(params)
    if finance_setting.present?
      finance_setting.update(params)
    else
      create_finance_setting(params)
    end
  end

  # Generate next payment for all members
  def generate_payments
    return 0 unless has_finance_enabled?

    result = {
      created: 0,
      skipped: 0,
      errors: 0,
      messages: []
    }

    memberships.approved.includes(:payments, :user).each do |membership|
      # Skip if the member already has a pending or paid payment
      if membership.payments.pending.or(membership.payments.paid).exists?
        result[:skipped] += 1
        result[:messages] << "Skipped payment for #{membership.user.email_address} - already has a pending/paid payment"
        next
      end

      due_date = finance_setting.next_due_date
      period = finance_setting.period_name

      # Create payment with explicit status
      payment = membership.payments.new(
        amount: finance_setting.amount,
        due_date: due_date,
        period: period,
        status: "pending" # Explicitly set status
      )

      if payment.save
        result[:created] += 1
        result[:messages] << "Created pending payment for #{membership.user.email_address}"
      else
        result[:errors] += 1
        error_message = "Failed to create payment for #{membership.user.email_address}: #{payment.errors.full_messages.join(', ')}"
        result[:messages] << error_message
        Rails.logger.error(error_message)
      end
    end

    Rails.logger.info("Generated #{result[:created]} payments. " +
                     "Skipped: #{result[:skipped]}. " +
                     "Errors: #{result[:errors]}")
    result[:created]
  end
end
