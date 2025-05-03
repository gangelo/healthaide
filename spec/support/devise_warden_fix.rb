# Fix for Rails 8.0+ Devise Warden mapping issues in tests
# This patch prevents the error "Could not find a valid mapping for #<User...>"

require 'warden'

if Rails::VERSION::MAJOR >= 8
  # Add a patch to Warden to fix the mapping lookup in Rails 8+
  module WardenMappingFix
    def lookup_mapping_for(obj)
      return nil unless obj

      # Force user mapping to be available in tests
      if obj.is_a?(User)
        return Warden::Proxy.new({})
               .mapping_for_serialization(obj) ||
               Devise.mappings[:user]
      end

      # Original behavior
      super
    end
  end

  # Apply the patch to Warden::Manager
  Warden::Manager.prepend(WardenMappingFix)
end

# Configure RSpec to set up Warden test helpers
RSpec.configure do |config|
  config.include Warden::Test::Helpers

  config.before(:suite) do
    Warden.test_mode!
  end

  config.after(:each) do
    Warden.test_reset!
  end
end

# Make sure the mapping exists
Devise.setup do |config|
  # Ensure Devise knows about the User model
  Devise.add_mapping(:user, {
    class_name: 'User',
    module: [ :database_authenticatable, :registerable, :recoverable,
             :rememberable, :validatable, :confirmable, :lockable,
             :timeoutable, :trackable ]
  })
end
