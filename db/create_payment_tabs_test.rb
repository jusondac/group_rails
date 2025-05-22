#!/usr/bin/env ruby
# This script creates test payments for each status to test tab functionality

puts "Creating test payments for tab functionality testing..."

# Find a community with finance settings
community = Community.first
if !community
  puts "No communities found. Creating one..."
  community = Community.create(name: "Test Community", description: "For testing payments")
  puts "Created community: #{community.name}"
end

if !community.finance_setting
  puts "Creating finance settings..."
  community.create_finance_setting(amount: 25.0, frequency: "monthly", active: true)
  puts "Finance settings created with monthly fee of $25"
end

# Ensure we have a user and membership
user = User.first || User.create(email_address: "test@example.com", password_digest: "password")
membership = Membership.find_by(user: user, community: community)

if !membership
  puts "Creating test membership..."
  membership = Membership.create(
    user: user,
    community: community,
    role: "member",
    status: "approved"
  )
  puts "Created membership for #{user.email_address}"
end

# Create one of each payment status
statuses = [ "pending", "paid", "overdue" ]

statuses.each do |status|
  # Skip if we already have this status
  next if membership.payments.where(status: status).exists?

  # Create payment with this status
  payment = membership.payments.new(
    amount: community.finance_setting.amount,
    due_date: status == "overdue" ? Date.today - 10.days : Date.today + 10.days,
    period: "May 2025",
    status: status
  )

  if status == "paid"
    payment.paid_at = Date.today - 2.days
  end

  if payment.save
    puts "Created #{status} payment for #{membership.user.email_address}"
  else
    puts "Failed to create #{status} payment: #{payment.errors.full_messages.join(', ')}"
  end
end

# Summary
puts "Pending payments: #{Payment.pending.count}"
puts "Paid payments: #{Payment.paid.count}"
puts "Overdue payments: #{Payment.overdue.count}"
