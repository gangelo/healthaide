require "ruby_llm"

module Ai
  class ChatStreamService
    # stream_target_id: The id of the html element to receive the stream response.
    # See: https://rubyllm.com/guides/streaming
    def initialize(chat, prompt:, stream_target_id:)
      @chat             = chat
      @prompt           = prompt
      @stream_target_id = stream_target_id

      @chat_service = Ai::ChatService.new(chat)

      raise ArgumentError, "Argument :prompt is not present?" unless prompt.present?
      raise ArgumentError, "Argument :stream_target_id is not present?" unless stream_target_id.present?
    end

    def execute!
      Rails.logger.debug { "Executing chat stream service for chat: #{chat.id}, stream_target_id: #{stream_target_id}..." }

      # Broadcast an initial placeholder
      broadcast_stream(stream_response: "Thinking...")

      stream_response = ""

      # Broadcast updates, replacing the placeholder content
      chat_service.ask(prompt) do |chunk|
        stream_response << (chunk.content || "")
        broadcast_stream(stream_response:)
      end

      Rails.logger.debug { "Done executing chat stream service for chat: #{chat.id}, stream_target_id: #{stream_target_id}!" }
    end

    private

    attr_reader :chat, :chat_service, :prompt, :stream_target_id

    def broadcast_stream(stream_response:)
      Rails.logger.debug("xyzzy: streaming: #{stream_response}")

      Turbo::StreamsChannel.broadcast_update_to(
          "chat_#{chat.id}",
          target: stream_target_id,
          html: ActionController::Base.helpers.simple_format(stream_response).html_safe
        )
    end
  end
end
