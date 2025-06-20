require "ruby_llm"

module Ai
  # See: https://rubyllm.com/configuration
  #      https://rubyllm.com/configuration#provider-api-keys
  # Also: https://docs.anthropic.com/en/api/client-sdks
  #
  # Example usage:
  # user = User.find_by(last_name: "Angelo")
  # service = Ai::ProviderChatService.new(user)
  #
  # service.with_instructions("Just return your output like a simple calculator; no commentary please!")
  # service.ask("what is the sum of 2 + 2?")
  # service.ask("what would be the sum if I added 5?")
  #
  # service.history
  # => [{role: :system, content: "Just return your output like a simple calculator; no commentary please!"},
  #     {role: :user, content: "what is the sum of 2 + 2?"},
  #     {role: :assistant, content: "4"},
  #     {role: :user, content: "what would be the sum if I added 5?"},
  #     {role: :assistant, content: "9"}]
  class ProviderChatService
    private delegate :ai_provider, :ai_provider_model, :ai_provider_api_key, :no_provider?, to: :user_profile

    # ask(prompt)
    # with_instructions(instructions, replace: <true || false>)
    # See: https://rubyllm.com/guides/chat#guiding-the-ai-with-instructions
    delegate :ask, :with_instructions, to: :chat

    def initialize(user)
      @user_profile = user.profile

      raise ArgumentError, "AI provider #{ai_provider} is not a valid provider" if no_provider?
    end

    # Returns the chat history
    def history
      chat.messages.map do |message|
        { role: message.role, content: message.content }
      end
    end

    private

    attr_reader :user_profile

    def context
      @context ||= RubyLLM.context do |config|
        # https://rubyllm.com/configuration#provider-api-keys
        config.public_send("#{ai_provider}_api_key=", ai_provider_api_key)
      end
    end

    def chat
      @chat ||= context.chat(model: ai_provider_model, provider: ai_provider)
    end
  end
end
