# This controller handles user meal prompts and generates
# the meals using AI if it is configured.
class Ai::UserMealChatsController < ApplicationController
  before_action :set_user_meal_prompt, only: %i[ create ]
  before_action :set_user_meal_prompt_chat, only: %i[ show ]

  # GET ai/user_meal_chats/new
  def new
    # TODO: Implement a Chat model.
    # @chat = current_user.build_chat(meal_prompt:)
  end

  # POST ai/user_meal_chats/create
  def create
    @content = ""
    @stream_target_id = "stream_#{SecureRandom.uuid}"
    prompt = decorate(@user_meal_prompt, UserMealPromptDecorator).full_formatted_prompt
    chat = Ai::UserMealPromptChatCreatorService.new(current_user).create!
    # TODO: What to do here?
    chat.with_instructions("Render an html response using inline styling using tailwind css v#{Gem.loaded_specs["tailwindcss-rails"]&.version}. DO NOT USE MARKDOWN CODE BLOCKS (e.g. html```...```).")
    # chat.with_instructions("Render the response as html using inline css styling. DO NOT USE MARKDOWN CODE BLOCKS (e.g. html```...```).")
    chat.save!
    @chat_id = chat.id

    # Start the streaming job asynchronously after rendering the view
    Ai::UserMealPromptChatStreamJob.perform_later(chat_id: @chat_id, prompt:, stream_target_id: @stream_target_id)
  end

  # GET ai/user_meal_chats/edit
  def edit
  end

  # GET ai/user_meal_chats/show
  def show
  end

  # PUT ai/user_meal_chats/update
  def update
    # TODO: Update the user chat object, and redirect back to edit.
    redirect_to edit_ai_meal_prompt, flash: { notice: "Conversation updated" }
  end

  private

  def set_user_meal_prompt
    @user_meal_prompt = current_user.user_meal_prompt
  end

  def set_user_meal_prompt_chat
    @user_meal_prompt_chat = current_user.user_meal_prompt_chats.last
  end
end
