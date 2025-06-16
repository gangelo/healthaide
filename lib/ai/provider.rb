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

    AI_PROVIDER_MODELS = {
      AI_PROVIDER_NONE => [
        {
          model: AI_PROVIDER_NONE,
          notes: "No AI provider"
        }
      ],
      AI_PROVIDER_ANTHROPIC => [
        {
          model: "claude-opus-4-20250514",
          notes: "Premium flagship model. Best for complex reasoning, advanced coding, and tasks requiring maximum intelligence. Most expensive but most capable."
        },
        {
          model: "claude-sonnet-4-20250514",
          notes: "Balanced high-performance model. Great for most professional tasks with excellent reasoning and efficiency at moderate cost."
        },
        {
          model: "claude-3-5-haiku-20241022",
          notes: "Fast and budget-friendly option. Perfect for quick responses, simple tasks, and high-volume applications where speed and cost matter most."
        }
      ],

      AI_PROVIDER_OPENAI => [
        {
          model: "gpt-4.1-2025-04-14",
          notes: "Latest flagship model. Best for complex coding and instruction following with 1M token context for large documents. Premium pricing."
        },
        {
          model: "gpt-4.1-nano",
          notes: "Fastest and most affordable option. Perfect for simple tasks, classifications, and applications requiring quick responses on a budget."
        },
        {
          model: "o3",
          notes: "Specialized reasoning model. Excels at complex problem-solving, math, science, and deep logical thinking. Use when you need the best reasoning performance."
        }
      ],

      AI_PROVIDER_GEMINI => [
        {
          model: "gemini-2.5-pro-preview-06-05",
          notes: "Most advanced Gemini model with 'Deep Think' reasoning and 2M token context. Best for complex analysis and massive documents."
        },
        {
          model: "gemini-2.5-flash-preview-05-20",
          notes: "Balanced workhorse model with thinking capabilities. Excellent performance-to-cost ratio for most business applications."
        },
        {
          model: "gemini-2.0-flash-lite",
          notes: "Budget-friendly option with solid performance. Perfect for high-volume applications where cost efficiency is the priority."
        }
      ],

      AI_PROVIDER_DEEPSEEK => [
        {
          model: "deepseek-reasoner",
          notes: "Advanced reasoning model at breakthrough pricing. Shows 'thinking' process and rivals expensive alternatives for math, coding, and logic at a fraction of the cost."
        },
        {
          model: "deepseek-chat",
          notes: "Extremely cost-effective general model. Best value for everyday tasks where you need capable AI performance without premium pricing."
        }
      ]
    }.freeze

    module_function

    # NOTE: This method will return true for AI_PROVIDER_NONE.
    def valid_provider?(provider)
      ALL_AI_PROVIDERS.include?(provider)
    end

    # Given an AI_PROVIDER_XXX, returns the models associated with the provider
    # as an array of hashes. For example:
    # [
    #   { "claude-opus-4-20250514"   => "Premium flagship model..." },
    #   { "claude-sonnet-4-20250514" => "Balanced high-performance model..." }
    # ]
    def models_for(provider)
      return {} unless valid_provider?(provider)

      AI_PROVIDER_MODELS[provider].each_with_object({}) do |model, hash|
        hash[model[:model]] = model[:notes]
      end
    end
  end
end
