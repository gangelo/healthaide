# This controller handles user meal prompts and generates
# the meals using AI if it is configured.
class Ai::UserMealChatsController < ApplicationController
  before_action :set_meal_prompt, only: %i[ :new ]
  before_action :set_chat, only: %i[ :edit, :update ]

  # GET ai/meal_prompts#new
  def new
    # TODO: Implement a Chat model.
    # @chat = current_user.build_chat(meal_prompt:)
  end

  # POST ai/meal_prompts#create
  def create
    # TODO: Create the Chat from the form that was posted.
  end

  # GET ai/meal_prompts#edit
  def edit
    # TODO: Continue with the Cat conversation started from :new/:create.
  end

  # PUT ai/meal_prompts#update
  def update
    # TODO: Update the user chat object, and redirect back to edit.
    redirect_to edit_ai_meal_prompt, flash: { notice: "Conversation updated" }
  end

  private

  def set_meal_prompt
    @meal_prompt = current_user.user_meal_prompt
  end
end
