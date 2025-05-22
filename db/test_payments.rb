#!/usr/bin/env ruby
# This script creates test payments for testing the payment tab functionality

# Get a community with finance settings
community = Community.first
if !community || !community.finance_setting
  puts "Creating a finance setting for the first community..."
  community = Community.first
  if community
    community.create_finance_setting(amount: 25.0, frequency: "monthly", active: true) unless community.finance_setting
  else
    puts "No communities found. Please run the seeds first."
    exit
  end
end

# Verify memberships exist
if community.memberships.approved.empty?
  puts "No approved memberships found in the first community. Please run the seeds first."
  exit
end

# Create payments with different statuses
puts "Creating test payments..."

# Create pending payments
community.memberships.approved.each_with_index do |membership, index|
  # Skip if the member already has a pending payment
  next if membership.payments.pending.exists?

  # Create a pending payment
  payment = membership.payments.create(
    amount: community.finance_setting.amount,
    due_date: Date.today + 10.days,
    period: "May 2025",
    status: "pending"
  )

  puts "Created pending payment for #{membership.user.email_address}: #{payment.persisted? ? 'Success' : 'Failed'}"
  puts payment.errors.full_messages.join(", ") unless payment.persisted?
end

# Create paid payments (mark some pending as paid)
community.payments.pending.limit(2).each do |payment|
  payment.update(status: "paid", paid_at: Date.today - 5.days)
  puts "Marked payment for #{payment.membership.user.email_address} as paid"
end

# Create overdue payments
community.memberships.approved.limit(2).each do |membership|
  # Skip if the member already has an overdue payment
  next if membership.payments.overdue.exists?

  payment = membership.payments.create(
    amount: community.finance_setting.amount,
    due_date: Date.today - 5.days,
    period: "April 2025",
    status: "overdue"
  )

  puts "Created overdue payment for #{membership.user.email_address}: #{payment.persisted? ? 'Success' : 'Failed'}"
  puts payment.errors.full_messages.join(", ") unless payment.persisted?
end

puts "Done creating test payments."
puts "Total payments: #{Payment.count}"
puts "Pending payments: #{Payment.pending.count}"
puts "Paid payments: #{Payment.paid.count}"
puts "Overdue payments: #{Payment.overdue.count}"
