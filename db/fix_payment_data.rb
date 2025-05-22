#!/usr/bin/env ruby
# This script fixes inconsistent or invalid payment data

puts "Checking for payments with invalid data..."

# Count of fixed records
fixed_records = 0

# Find payments with nil due dates
nil_due_date_payments = Payment.where(due_date: nil)
puts "Found #{nil_due_date_payments.count} payments with nil due_date"

# Fix payments with nil due dates
nil_due_date_payments.each do |payment|
  # Set due date based on period or creation date
  if payment.period.present? && payment.period_start.present?
    payment.update(due_date: payment.period_end)
    puts "Fixed payment ##{payment.id} with period-based due date: #{payment.due_date}"
  else
    default_due_date = payment.created_at.present? ? payment.created_at.to_date + 30.days : Date.today + 30.days
    payment.update(due_date: default_due_date)
    puts "Fixed payment ##{payment.id} with default due date: #{payment.due_date}"
  end
  fixed_records += 1
end

# Find payments with invalid period formats
invalid_period_payments = Payment.all.select do |payment|
  begin
    payment.period_start
    payment.period_end
    false # No error, so not invalid
  rescue => e
    puts "Error with payment ##{payment.id} period (#{payment.period}): #{e.message}"
    true # Error occurred, so invalid
  end
end

puts "Found #{invalid_period_payments.count} payments with invalid period formats"

# Fix payments with invalid periods
invalid_period_payments.each do |payment|
  # Set a default period based on due date or current date
  reference_date = payment.due_date || payment.created_at&.to_date || Date.today
  default_period = "#{Date::MONTHNAMES[reference_date.month]} #{reference_date.year}"

  payment.update(period: default_period)
  puts "Fixed payment ##{payment.id} with default period: #{payment.period}"
  fixed_records += 1
end

puts "Finished fixing #{fixed_records} payment records."
