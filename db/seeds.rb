# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Starting seed process..."

# Default password for all users
DEFAULT_PASSWORD = "q1w2e3r4"

# Create initial admin users
user1 = User.create_or_find_by(email_address: "user@gmail.com") do |user|
  user.password = DEFAULT_PASSWORD
  user.password_confirmation = DEFAULT_PASSWORD
end

user2 = User.create_or_find_by(email_address: "admin@gmail.com") do |user|
  user.password = DEFAULT_PASSWORD
  user.password_confirmation = DEFAULT_PASSWORD
end

user3 = User.create_or_find_by(email_address: "member@gmail.com") do |user|
  user.password = DEFAULT_PASSWORD
  user.password_confirmation = DEFAULT_PASSWORD
end

puts "Created initial admin users"

# Create 97 more users (for a total of 100)
97.times do |i|
  User.create_or_find_by(email_address: "user#{i+4}@example.com") do |user|
    user.password = DEFAULT_PASSWORD
    user.password_confirmation = DEFAULT_PASSWORD
  end
end

puts "Created 97 additional users"

# Sample community categories
community_categories = [
  { name: "Technology", topics: [ "Programming", "DevOps", "Web Development", "Mobile Apps", "Data Science", "AI", "Cloud Computing", "Cybersecurity" ] },
  { name: "Hobbies", topics: [ "Photography", "Cooking", "Gardening", "Crafts", "DIY", "Reading", "Writing", "Music", "Art" ] },
  { name: "Sports", topics: [ "Football", "Basketball", "Baseball", "Soccer", "Tennis", "Golf", "Swimming", "Running", "Cycling" ] },
  { name: "Education", topics: [ "Mathematics", "Science", "History", "Languages", "Literature", "Philosophy", "Engineering" ] },
  { name: "Professional", topics: [ "Business", "Marketing", "Finance", "Entrepreneurship", "HR", "Leadership", "Project Management" ] },
  { name: "Social", topics: [ "Meetups", "Networking", "Social Events", "Charity", "Volunteering" ] }
]

# Create public communities
community1 = Community.create_or_find_by(name: "Ruby Programming") do |community|
  community.description = "A community for Ruby programmers to share knowledge and help each other."
  community.private = false
end

community2 = Community.create_or_find_by(name: "Rails Developers") do |community|
  community.description = "Discussion about Ruby on Rails framework, best practices, and tutorials."
  community.private = false
end

# Create private community
community3 = Community.create_or_find_by(name: "Advanced Ruby Projects") do |community|
  community.description = "A private community for advanced Ruby projects and pair programming."
  community.private = true
end

# Create more communities (total 20)
communities = [ community1, community2, community3 ]

17.times do |i|
  category = community_categories.sample
  topic = category[:topics].sample
  name = "#{topic} #{[ "Club", "Community", "Group", "Network", "Hub" ].sample}"

  # Create community with a more reliable method
  community = Community.find_by(name: name)

  if community.nil?
    community = Community.create!(
      name: name,
      description: "A #{category[:name].downcase} community focused on #{topic.downcase}.",
      private: [ true, false ].sample
    )
  end

  communities << community if community.present? && community.persisted?

  # Create a finance setting for 30% of communities
  if i % 3 == 0 && community.present? && community.persisted?
    # Make sure community doesn't already have a finance setting
    unless FinanceSetting.exists?(community_id: community.id)
      FinanceSetting.create!(
        community_id: community.id,
        amount: rand(5..50),
        frequency: [ "weekly", "monthly", "yearly" ].sample,
        active: true
      )
    end
  end
end

puts "Created #{communities.size} communities"

# Create memberships
# User 1 is admin of Ruby Programming and member of Rails Developers
if community1.present? && community1.persisted?
  Membership.create_or_find_by(user: user1, community: community1) do |membership|
    membership.role = "admin"
    membership.status = "approved"
  end
  puts "Created admin membership for user1 in #{community1.name}"
else
  puts "Skipping membership creation: community1 not available"
end

if community2.present? && community2.persisted?
  Membership.create_or_find_by(user: user1, community: community2) do |membership|
    membership.role = "member"
    membership.status = "approved"
  end
  puts "Created member membership for user1 in #{community2.name}"
else
  puts "Skipping membership creation: community2 not available"
end

# User 2 is admin of Rails Developers and Advanced Ruby Projects
if community2.present? && community2.persisted?
  Membership.create_or_find_by(user: user2, community: community2) do |membership|
    membership.role = "admin"
    membership.status = "approved"
  end
  puts "Created admin membership for user2 in #{community2.name}"
else
  puts "Skipping membership creation: community2 not available"
end

if community3.present? && community3.persisted?
  Membership.create_or_find_by(user: user2, community: community3) do |membership|
    membership.role = "admin"
    membership.status = "approved"
  end
  puts "Created admin membership for user2 in #{community3.name}"
else
  puts "Skipping membership creation: community3 not available"
end

# User 3 is member of Ruby Programming and has a pending request for Advanced Ruby Projects
if community1.present? && community1.persisted?
  Membership.create_or_find_by(user: user3, community: community1) do |membership|
    membership.role = "member"
    membership.status = "approved"
  end
  puts "Created member membership for user3 in #{community1.name}"
else
  puts "Skipping membership creation: community1 not available"
end

if community3.present? && community3.persisted?
  Membership.create_or_find_by(user: user3, community: community3) do |membership|
    membership.role = "member"
    membership.status = "pending"
  end
  puts "Created pending membership for user3 in #{community3.name}"
else
  puts "Skipping membership creation: community3 not available"
end

# Create more memberships
all_users = User.all.to_a
membership_statuses = [ "approved", "pending" ]

# Each user joins 2-5 communities
all_users.each do |user|
  # Skip initial users who already have memberships
  next if [ user1.id, user2.id, user3.id ].include?(user.id)

  # Join 2-5 random communities
  rand(2..5).times do
    community = communities.sample

    # Skip if community is nil or not persisted (defensive coding)
    next unless community && community.persisted?

    status = membership_statuses.sample

    # Private communities have more pending requests
    status = "pending" if community.private? && rand < 0.7

    # Only ~10% of users are admins
    role = rand < 0.1 ? "admin" : "member"

    # Create membership if it doesn't exist
    unless Membership.exists?(user: user, community: community)
      begin
        Membership.create!(
          user: user,
          community: community,
          role: role,
          status: status
        )
      rescue => e
        puts "Error creating membership for user #{user.id} in community #{community.id}: #{e.message}"
      end
    end
  end
end

puts "Created memberships"

# Create events
event_types = [
  "Meetup", "Workshop", "Conference", "Hackathon", "Talk", "Presentation",
  "Discussion", "Q&A Session", "Panel", "Social", "Networking", "Demo Day"
]

# Create future events
communities.each do |community|
  # Make sure community is saved
  next unless community.persisted?

  # Create 1-4 upcoming events per community
  rand(1..4).times do
    start_date = Date.today + rand(1..60).days
    end_date = start_date + rand(1..8).hours
    
    admin_membership = community.memberships.where(role: "admin").sample
    creator = admin_membership&.user || User.all.sample

    begin
      event = community.events.create!(
        name: "#{community.name} #{event_types.sample}",
        description: "Join us for this exciting event with the #{community.name} community!",
        start_date: start_date,
        end_date: end_date,
        location: [ "Virtual", "Community Center", "Downtown Office", "Tech Hub", "University Campus", "Innovation Center" ].sample,
        private: [ true, false ].sample,
        created_by: creator
      )

      # Add 3-15 participants to each event if event was created
      if event.persisted?
        rand(3..15).times do
          user = all_users.sample

          # Only community members can join private events
          if event.private?
            membership = Membership.find_by(user: user, community: community, status: "approved")
            next unless membership
          end

          status = [ "attending", "maybe", "declined" ].sample

          # Create participant record
          begin
            EventParticipant.create_or_find_by(event: event, user: user) do |ep|
              ep.status = status
            end
          rescue => e
            puts "Error creating event participant: #{e.message}"
          end
        end
      end
    rescue => e
      puts "Error creating event for community #{community.name}: #{e.message}"
    end
  end

  # Create 0-3 past events per community
  rand(0..3).times do
    start_date = Date.today - rand(1..90).days
    end_date = start_date + rand(1..8).hours
    
    admin_membership = community.memberships.where(role: "admin").sample
    creator = admin_membership&.user || User.all.sample

    begin
      event = community.events.create!(
        name: "Past #{community.name} #{event_types.sample}",
        description: "This was a great event with the #{community.name} community!",
        start_date: start_date,
        end_date: end_date,
        location: [ "Virtual", "Community Center", "Downtown Office", "Tech Hub", "University Campus", "Innovation Center" ].sample,
        private: [ true, false ].sample,
        created_by: creator
      )

      # Add 5-25 participants to each past event if event was created
      if event.persisted?
        rand(5..25).times do
          user = all_users.sample

          # For past events, most people attended
          status = [ "attending", "attending", "attending", "attending", "maybe", "declined" ].sample

          # Create participant record
          begin
            EventParticipant.create_or_find_by(event: event, user: user) do |ep|
              ep.status = status
            end
          rescue => e
            puts "Error creating past event participant: #{e.message}"
          end
        end
      end
    rescue => e
      puts "Error creating past event for community #{community.name}: #{e.message}"
    end
  end
end

puts "Created events and participants"

# Generate payments for communities with finance settings
communities.each do |community|
  next unless community.persisted? && community.finance_setting&.active?

  # Get all approved members
  members = community.memberships.approved

  members.each do |membership|
    next unless membership.persisted?
    
    # Create 1-5 payments per member
    rand(1..5).times do |i|
      amount = community.finance_setting.amount

      # Determine period based on frequency
      case community.finance_setting.frequency
      when "weekly"
        period_start = Date.today - (i * 7 + rand(0..7)).days
      when "monthly"
        period_start = Date.today - (i * 30 + rand(0..30)).days
      when "yearly"
        period_start = Date.today - (i * 365 + rand(0..30)).days
      end

      due_date = period_start + 3.days

      # Format period string based on frequency
      period_string = case community.finance_setting.frequency
      when "weekly"
        "Week #{period_start.strftime('%W')}, #{period_start.year}"
      when "monthly"
        period_start.strftime('%B %Y')
      when "yearly"
        "#{period_start.year}"
      end

      # Randomly decide if payment is paid, pending, or overdue
      status = if i.zero?
                 [ "pending", "pending", "pending", "paid" ].sample
      else
                 [ "paid", "paid", "overdue" ].sample
      end

      begin
        payment = membership.payments.create!(
          amount: amount,
          status: status,
          period: period_string,
          due_date: due_date
        )

        # Set paid_at for paid payments
        if payment.persisted? && payment.paid?
          payment.update(paid_at: due_date - rand(0..3).days)
        end
      rescue => e
        puts "Error creating payment for membership #{membership.id}: #{e.message}"
      end
    end
  end
end

puts "Created payments for communities with finance settings"

puts "Seeds completed: Created 100 users, #{communities.size} communities, #{Event.count} events, and #{Payment.count} payments"
