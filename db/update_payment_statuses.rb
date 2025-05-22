#!/usr/bin/env ruby
# This script updates payment statuses based on the due date
# It marks payments as overdue if they are past their due date and still pending

puts "Updating payment statuses..."
overdue_count = 0
fixed_count = 0

# Find all pending payments
pending_payments = Payment.pending

pending_payments.each do |payment|
  # Check if payment is overdue
  if payment.due_date < Date.current
    # Mark as overdue
    payment.update(status: "overdue")
    overdue_count += 1
    puts "Marked payment ##{payment.id} for #{payment.membership.user.email_address} as overdue"
  end

  # Verify and fix period_start and period_end
  begin
    payment.period_start
    payment.period_end
  rescue => e
    # Try to fix the period field if there's an error
    puts "Error with payment ##{payment.id} period: #{e.message}"
    if payment.period.nil?
      # Set a default period based on due date
      payment.update(period: payment.membership.community.finance_setting.period_name(payment.due_date))
      fixed_count += 1
      puts "Fixed payment ##{payment.id} period to #{payment.period}"
    end
  end
end

# Summary
puts "Updated #{overdue_count} payments to overdue status."
puts "Fixed #{fixed_count} payments with invalid period values."
puts "Pending payments: #{Payment.pending.count}"
puts "Paid payments: #{Payment.paid.count}"
puts "Overdue payments: #{Payment.overdue.count}"
