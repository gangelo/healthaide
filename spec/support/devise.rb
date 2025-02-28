RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :view
  # TODO: Not sure if this is needed.
  # config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

  # This is the critical addition - make sure Devise mappings are loaded for model tests
  # config.before(:each, type: :model) do
  #   @request = ActionController::TestRequest.create(ActionController::TestSession) if defined?(ActionController::TestRequest)
  # end
end
