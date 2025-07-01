require "ruby_llm"

module Ai
  # See: https://rubyllm.com/configuration
  #      https://rubyllm.com/configuration#provider-api-keys
  # Also: https://docs.anthropic.com/en/api/client-sdks
  #
  # Example usage:
  # user = User.find_by(last_name: "Angelo")
  # service = Ai::ChatService.new(user)
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
  class ChatService
    private delegate :ai_provider, :ai_provider_model, :ai_provider_api_key, :no_provider?, to: :user_profile

    def initialize(chat)
      @chat         = chat
      @user         = chat.user
      @user_profile = chat.user.profile

      raise ArgumentError, "Argument :chat is not present?" unless chat.present?
      raise ArgumentError, "Argument :chat is not persisted?" unless chat.persisted?
    end

    def ask(prompt, &)
      chat.with_context(context).ask(prompt, &)
    end

    def with_instructions(instructions, replace: false)
      chat.with_context(context).with_instructions(instructions, replace: replace)
      self
    end

    # Returns the chat history
    def history
      chat.messages.map do |message|
        { role: message.role, content: message.content }
      end
    end
    private

    attr_reader :chat, :user, :user_profile

    def context
      # https://rubyllm.com/configuration#provider-api-keys
      @context ||= RubyLLM.context do |config|
        config.public_send("#{ai_provider}_api_key=", ai_provider_api_key)
      end
    end
  end
end
