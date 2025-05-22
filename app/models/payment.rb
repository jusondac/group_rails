class Payment < ApplicationRecord
  belongs_to :membership

  validates :amount, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  validates :status, inclusion: { in: %w[pending paid overdue] }

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :paid, -> { where(status: "paid") }
  scope :overdue, -> { where(status: "overdue") }

  # Mark as paid
  def mark_as_paid!
    update(status: "paid", paid_at: Time.current)
  end

  # Check if payment is overdue
  def overdue?
    due_date < Date.current && status != "paid"
  end

  # Check if payment is paid
  def paid?
    status == "paid"
  end

  # Update payment status if it's overdue
  def update_status
    update(status: "overdue") if overdue? && status == "pending"
  end

  # Calculate period start date based on period string
  def period_start
    return nil if period.nil?

    begin
      if period.match(/Week (\d+), (\d+)/)
        # For weekly periods "Week 21, 2025"
        week = $1.to_i
        year = $2.to_i
        Date.commercial(year, week, 1) # Monday of the specified week
      elsif period.match(/(\w+) (\d+)/)
        # For monthly periods "May 2025"
        month_name = $1
        year = $2.to_i
        Date.parse("1 #{month_name} #{year}")
      else
        # For yearly periods "2025" or fallback for invalid formats
        if period.to_i > 0
          Date.new(period.to_i, 1, 1)
        else
          # Last resort fallback - use due date or current date
          (due_date || Date.today).beginning_of_month
        end
      end
    rescue => e
      Rails.logger.error("Error parsing period_start for payment #{id} with period '#{period}': #{e.message}")
      # Return a fallback date
      (due_date || Date.today).beginning_of_month
    end
  end

  # Calculate period end date based on period string
  def period_end
    return nil if period.nil?

    begin
      if period.match(/Week (\d+), (\d+)/)
        # For weekly periods
        week = $1.to_i
        year = $2.to_i
        Date.commercial(year, week, 7) # Sunday of the specified week
      elsif period.match(/(\w+) (\d+)/)
        # For monthly periods
        month_name = $1
        year = $2.to_i
        start_date = Date.parse("1 #{month_name} #{year}")
        end_of_month = Date.new(start_date.year, start_date.month, -1)
        end_of_month
      else
        # For yearly periods or fallback
        if period.to_i > 0
          Date.new(period.to_i, 12, 31)
        else
          # Last resort fallback - use due date or current date
          (due_date || Date.today).end_of_month
        end
      end
    rescue => e
      Rails.logger.error("Error parsing period_end for payment #{id} with period '#{period}': #{e.message}")
      # Return a fallback date
      (due_date || Date.today).end_of_month
    end
  end
end
