def init_common_user_attributes_for(user)
  time_current = Time.current

  user.password = ENV.fetch("SEED_USER_PASSWORD")
  user.password_confirmation = ENV.fetch("SEED_USER_PASSWORD")
  user.confirmed_at = time_current
  user.sign_in_count = 1
  user.current_sign_in_at = time_current
  user.last_sign_in_at = time_current
  user.current_sign_in_ip = "127.0.0.1"
  user.last_sign_in_ip = "127.0.0.1"
end

if Rails.env.development?
  puts "Creating users..."

  User.find_or_create_by!(username: "adam.user") do |user|
    user.role       = User::ROLE_USER
    user.first_name = "Adam"
    user.last_name  = "User"
    user.email      = "adam.user@nowhere.com"

    init_common_user_attributes_for(user)
  end

  User.find_or_create_by!(username: "bob.user") do |user|
    user.role       = User::ROLE_USER
    user.first_name = "Bob"
    user.last_name  = "User"
    user.email      = "bob.user@nowhere.com"

    init_common_user_attributes_for(user)
  end

  puts "Creating admin users..."

  User.find_or_create_by!(username: "joe.admin") do |user|
    user.role       = User::ROLE_ADMIN
    user.first_name = "Joe"
    user.last_name  = "Admin"
    user.email      = "joe.admin@nowhere.com"

    init_common_user_attributes_for(user)
  end

  User.find_or_create_by!(username: "gangelo") do |user|
    user.role       = User::ROLE_ADMIN
    user.first_name = "Gene"
    user.last_name  = "Angelo"
    user.email      = "gangelo@nowhere.com"

    init_common_user_attributes_for(user)
  end
end
