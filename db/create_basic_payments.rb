#!/usr/bin/env ruby
# Simple script to create test payments

# Find a community
community = Community.first
puts "Using community: #{community.name}"

# Create or get finance setting
if !community.finance_setting
  puts "Creating finance setting"
  community.create_finance_setting(amount: 25.0, frequency: "monthly", active: true)
end

# Check for memberships
if community.memberships.approved.empty?
  puts "Creating test membership"
  user = User.first || User.create!(email_address: "test@example.com", password_digest: SecureRandom.hex(10))
  membership = Membership.create!(user: user, community: community, status: "approved", role: "member")
end

# Create a pending payment
membership = community.memberships.approved.first
puts "Creating pending payment for: #{membership.user.email_address}"
payment = membership.payments.create!(
  amount: 25.0,
  due_date: Date.today + 10.days,
  period: "May 2025",
  status: "pending"
)
puts "Created pending payment: #{payment.id}"

# Create a paid payment
puts "Creating paid payment"
payment = membership.payments.create!(
  amount: 25.0,
  due_date: Date.today - 10.days,
  paid_at: Date.today - 5.days,
  period: "April 2025",
  status: "paid"
)
puts "Created paid payment: #{payment.id}"

# Create an overdue payment
puts "Creating overdue payment"
payment = membership.payments.create!(
  amount: 25.0,
  due_date: Date.today - 15.days,
  period: "March 2025",
  status: "overdue"
)
puts "Created overdue payment: #{payment.id}"

puts "Done creating payments"
puts "Pending: #{Payment.pending.count}"
puts "Paid: #{Payment.paid.count}"
puts "Overdue: #{Payment.overdue.count}"
