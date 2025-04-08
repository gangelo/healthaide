if Rails.env.development?
  puts "Creating admin user..."

  User.find_or_create_by!(username: "admin") do |user|
    user.role = User::ROLE_ADMIN

    user.first_name = "Admin"
    user.last_name = "User"
    user.email = "admin.user@nowhere.com"
    user.password = ENV.fetch("SEED_ADMIN_USER_PASSWORD")
    user.password_confirmation = ENV.fetch("SEED_ADMIN_USER_PASSWORD")

    user.confirmed_at = Time.current

    user.sign_in_count = 1
    user.current_sign_in_at = Time.current
    user.last_sign_in_at = Time.current
    user.current_sign_in_ip = "127.0.0.1"
    user.last_sign_in_ip = "127.0.0.1"
  end
end
