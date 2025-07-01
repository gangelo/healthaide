module Ai
  class UserMealPromptChatStreamJob < ApplicationJob
    queue_as :default

    rescue_from(ActiveRecord::RecordNotFound) do |exception|
      # TODO: Do something with the exception
      Rails.error.report(exception)
      raise exception
    end

    rescue_from(Exception) do |exception|
      # TODO: Do something with the exception
      Rails.error.report(exception)
      raise exception
    end

    def perform(chat_id:, prompt:, stream_target_id:)
       Rails.logger.debug { "Running user meal prompt chat stream job for chat_id: #{chat_id}, stream_target_id: #{stream_target_id}..." }

       UserMealPromptChat.find(chat_id).tap do |chat|
        Ai::ChatStreamService.new(chat, prompt:, stream_target_id:).execute!
       end
    end
  end
end
