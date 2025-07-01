FactoryBot.define do
  factory :user_profile do
    ai_provider { Ai::Provider::AI_PROVIDER_NONE }
    ai_provider_model { nil }
    ai_provider_api_key { nil }

    association :user

    trait :no_provider do
      ai_provider { Ai::Provider::AI_PROVIDER_NONE }
    end

    trait :anthropic do
      ai_provider         { Ai::Provider::AI_PROVIDER_ANTHROPIC }
      ai_provider_model   { Ai::Provider.models_for(Ai::Provider::AI_PROVIDER_ANTHROPIC).keys.sample }
      ai_provider_api_key { "#{Ai::Provider::AI_PROVIDER_ANTHROPIC}-api-key" }
    end

    trait :deepseek do
      ai_provider { Ai::Provider::AI_PROVIDER_DEEPSEEK }
      ai_provider_model   { Ai::Provider.models_for(Ai::Provider::AI_PROVIDER_DEEPSEEK).keys.sample }
      ai_provider_api_key { "#{Ai::Provider::AI_PROVIDER_DEEPSEEK}-api-key" }
    end

    trait :gemini do
      ai_provider { Ai::Provider::AI_PROVIDER_GEMINI }
      ai_provider_model   { Ai::Provider.models_for(Ai::Provider::AI_PROVIDER_GEMINI).keys.sample }
      ai_provider_api_key { "#{Ai::Provider::AI_PROVIDER_GEMINI}-api-key" }
    end

    trait :openai do
      ai_provider { Ai::Provider::AI_PROVIDER_OPENAI }
      ai_provider_model   { Ai::Provider.models_for(Ai::Provider::AI_PROVIDER_OPENAI).keys.sample }
      ai_provider_api_key { "#{Ai::Provider::AI_PROVIDER_OPENAI}-api-key" }
    end
  end
end
