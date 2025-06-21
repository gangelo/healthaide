class UserProfile < ApplicationRecord
  belongs_to :user

  before_save :nil_api_key_and_model_if_no_provider

  enum :ai_provider,
    # Leave room to alphabetically insert future providers.
    Ai::Provider::AI_PROVIDER_NONE      => 0,
    Ai::Provider::AI_PROVIDER_ANTHROPIC => 10,
    Ai::Provider::AI_PROVIDER_DEEPSEEK  => 20,
    Ai::Provider::AI_PROVIDER_GEMINI    => 30,
    Ai::Provider::AI_PROVIDER_OPENAI    => 40,
    default: Ai::Provider::AI_PROVIDER_NONE

  validates :ai_provider_api_key, presence: true, unless: -> { no_provider? }
  validates :ai_provider_model,   presence: true, unless: -> { no_provider? }
  validates :ai_provider_model,   inclusion: {
                                               in: ->(record) { Ai::Provider.models_for(record.ai_provider).keys },
                                               message: ->(object, data) { "'#{data[:value]}' is not a valid model for AI provider '#{object.ai_provider}'" }
                                             }, unless: -> { no_provider? }


  def ai_configured?
    !no_provider?
  end

  # Rails override.
  # We're overridding this method to make sure that ai_provider_api_key and
  # ai_model get nil'ed out if ai_provider is Ai::Provider::AI_PROVIDER_NONE.
  # This is because the default rails behavior is to update the database
  # directly and bypass before_save hooks.
  def no_provider!
    self.ai_provider = Ai::Provider::AI_PROVIDER_NONE
    nil_api_key_and_model_if_no_provider

    save!
  end

  private

  def nil_api_key_and_model_if_no_provider
    if no_provider?
      self.ai_provider_api_key = nil
      self.ai_provider_model = nil
    end
  end
end
