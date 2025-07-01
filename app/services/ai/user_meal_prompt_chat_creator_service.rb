module Ai
  class UserMealPromptChatCreatorService
    private delegate :ai_provider, :ai_provider_model, :ai_provider_api_key, :no_provider?, to: :user_profile

    def initialize(user)
      @user         = user
      @user_profile = user.profile

      raise ArgumentError, "Argument :user is not present?" unless user.present?
      raise ArgumentError, "AI provider #{ai_provider} is not a valid provider" if no_provider?
    end

    def create!
      chat
    end

    def chat
      @chat ||= user.user_meal_prompt_chats.create!(model_id: ai_provider_model)
    end

    private

    attr_reader :user, :user_profile
  end
end
