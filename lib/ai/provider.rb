module Ai
  module Provider
    AI_PROVIDER_NONE      = "no_provider".freeze
    AI_PROVIDER_ANTHROPIC = "anthropic".freeze
    AI_PROVIDER_DEEPSEEK  = "deepseek".freeze
    AI_PROVIDER_GEMINI    = "gemini".freeze
    AI_PROVIDER_OPENAI    = "openai".freeze

    ALL_AI_PROVIDERS = [
      AI_PROVIDER_NONE,
      AI_PROVIDER_ANTHROPIC,
      AI_PROVIDER_DEEPSEEK,
      AI_PROVIDER_GEMINI,
      AI_PROVIDER_OPENAI
    ].freeze

    module_function

    # NOTE: This method will return true for AI_PROVIDER_NONE.
    def valid_provider?(provider)
      # RubyLLM::Provider.providers.keys.map(&:to_s).include?(provider&.to_s)
      ALL_AI_PROVIDERS.include?(provider)
    end

    # Given a provider, returns:
    # {
    #   "claude-3-5-haiku" => {"anthropic" => "claude-3-5-haiku-20241022", "openrouter" => "anthropic/claude-3.5-haiku", "bedrock" => "anthropic.claude-3-5-haiku-20241022-v1:0"},
    #   "claude-3-5-sonnet" => {"anthropic" => "claude-3-5-sonnet-20241022", "openrouter" => "anthropic/claude-3.5-sonnet", "bedrock" => "anthropic.claude-3-5-sonnet-20240620-v1:0:200k"},
    #   "claude-3-7-sonnet" => {"anthropic" => "claude-3-7-sonnet-20250219", "openrouter" => "anthropic/claude-3.7-sonnet", "bedrock" => "us.anthropic.claude-3-7-sonnet-20250219-v1:0"},
    #   "claude-3-haiku" => {"anthropic" => "claude-3-haiku-20240307", "openrouter" => "anthropic/claude-3-haiku", "bedrock" => "anthropic.claude-3-haiku-20240307-v1:0:200k"},
    #   "claude-3-opus" => {"anthropic" => "claude-3-opus-20240229", "openrouter" => "anthropic/claude-3-opus", "bedrock" => "anthropic.claude-3-opus-20240229-v1:0:200k"},
    #   "claude-3-sonnet" => {"anthropic" => "claude-3-sonnet-20240229", "openrouter" => "anthropic/claude-3-sonnet", "bedrock" => "anthropic.claude-3-sonnet-20240229-v1:0:200k"},
    #   "claude-opus-4" => {"anthropic" => "claude-opus-4-20250514", "openrouter" => "anthropic/claude-opus-4", "bedrock" => "us.anthropic.claude-opus-4-20250514-v1:0"},
    #   "claude-sonnet-4" => {"anthropic" => "claude-sonnet-4-20250514", "openrouter" => "anthropic/claude-sonnet-4", "bedrock" => "us.anthropic.claude-sonnet-4-20250514-v1:0"},
    #   ...
    # }
    # https://rubyllm.com/guides/available-models
    def models_for(provider)
      RubyLLM::Aliases.aliases.each_with_object({}) do | model, hash |
        return {} unless valid_provider?(provider)

        if model[1].key?(provider)
          hash[model[0]] = model[1][provider]
        end
      end
    end

    def all_models
      ALL_AI_PROVIDERS.each_with_object({}) do | provider, hash |
        hash[provider] = [] unless hash.key?(provider)
        hash[provider] << models_for(provider)
      end
    end
  end
end
