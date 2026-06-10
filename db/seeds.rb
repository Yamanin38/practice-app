# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create test users
User.find_or_create_by!(username: "admin") do |user|
  user.password = "admin123"
  user.password_confirmation = "admin123"
  user.role = :admin
end

User.find_or_create_by!(username: "member") do |user|
  user.password = "member123"
  user.password_confirmation = "member123"
  user.role = :member
end

puts "Test users created successfully"

