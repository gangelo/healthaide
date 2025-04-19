RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

  # Configure system tests to use rack_test for speed, or switch to selenium for js testing
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end

  # Bypass confirmation for system tests
  config.before(:each, type: :system) do
    class User < ApplicationRecord
      def confirmation_required?
        false
      end

      def send_confirmation_instructions
        # Do nothing to bypass actual email sending
      end
    end
  end
end
