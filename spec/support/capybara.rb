# require 'capybara/rails'
# require 'capybara/rspec'
# require 'selenium-webdriver'

# Capybara.register_driver :selenium_chrome do |app|
#   options = Selenium::WebDriver::Chrome::Options.new
#   options.add_argument('--window-size=1400,1000')

#   Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
# end

# Capybara.javascript_driver = :selenium_chrome

# # Force initialization of the driver
# Capybara.current_driver = :selenium_chrome
# Capybara.visit('about:blank')  # Force browser to open
# Capybara.use_default_driver  # Switch back to default for tests
