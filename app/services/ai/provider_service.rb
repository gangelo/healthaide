module Ai
  # TODO: Make this into a wired model.
  class ProviderService
    # See: https://rubyllm.com/configuration
    #      https://rubyllm.com/configuration#provider-api-keys
    # Also: https://docs.anthropic.com/en/api/client-sdks

    ANTROPIC_API_KEY = ENV["ANTROPIC_API_KEY"].freeze
    DEEPSEEK_API_KEY = ENV["DEEPSEEK_API_KEY"].freeze
    GEMINI_API_KEY   = ENV["GEMINI_API_KEY"].freeze
    OPENAI_API_KEY = ENV["OPENAI_API_KEY"].freeze
    ALL_AI_PROVIDER_API_KEYS = [
      ANTROPIC_API_KEY
    ].freeze

    def initialize(user)
      @user = user
    end

    def execute(context: nil)
      context = context || RubyLLM.context do |config|
        yield config if block_given?
      end

      chat = context.chat(model: "claude-sonnet-4-20250514", provider: :anthropic)
    end

    private

    def provider
      :anthropic
      # :deepseek
      # :gemini
      # :openai
      # :openrouter
    end

    def anthropic?
      provider == :anthropic
    end

    def deepseek?
      provider == :deepseek
    end

    def gemini?
      provider == :gemini
    end

    def openai?
      provider == :openai
    end

    def openrouter?
      provider == :openrouter
    end

    def default_provider
      # find_by(default: true).provider
      :anthropic
    end

    def api_key
      # TODO: For now, hard-code this.
      ANTROPIC_API_KEY
    end

    def api_key_for(provider)
      provider = default_provider if provider == :default

      case provider
      when :anthropic
        # TODO: Add other providers here.
      else
        raise NotImplementedException, "Unimplemented provider: #{provider}"
      end
    end
  end
end
