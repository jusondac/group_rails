class FinanceSetting < ApplicationRecord
  belongs_to :community

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :frequency, inclusion: { in: %w[weekly monthly yearly] }

  # Calculate the next due date based on frequency
  def next_due_date(from_date = Date.current)
    case frequency
    when "weekly"
      from_date + 1.week
    when "monthly"
      from_date + 1.month
    when "yearly"
      from_date + 1.year
    end
  end

  # Generate period name for a payment
  def period_name(date = Date.current)
    case frequency
    when "weekly"
      "Week #{date.strftime('%U')}, #{date.year}"
    when "monthly"
      date.strftime("%B %Y")
    when "yearly"
      date.year.to_s
    end
  end
end
