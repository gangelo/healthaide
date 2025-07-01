# NOTE: All providers should be represented here; that is, all providers recognized
# in the lib/ai/provider.rb class.
#
# Unfortunately, in order to use context per user request, we need to do
# this silliness or we will receive an error when chatting, for example:
#
# RubyLLM::ConfigurationError: anthropic provider is not configured. Add this to your initialization: (RubyLLM::ConfigurationError)
#
# RubyLLM.configure do |config|
#   config.anthropic_api_key = ENV['ANTHROPIC_API_KEY']
# end
RubyLLM.configure do |config|
  config.openai_api_key    = ENV.fetch("OPENAI_API_KEY",    "dummy")
  config.anthropic_api_key = ENV.fetch("ANTHROPIC_API_KEY", "dummy")
  config.gemini_api_key    = ENV.fetch("GEMINI_API_KEY",    "dummy")
  config.deepseek_api_key  = ENV.fetch("DEEPSEEK_API_KEY",  "dummy")
end
