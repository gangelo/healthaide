require "webmock/rspec"

RSpec.configure do |config|
  config.before(:each, type: :service) do
    WebMock.enable!
  end

  config.after(:each, type: :service) do
    WebMock.reset!
    WebMock.disable!
  end
end
