# frozen_string_literal: true

module Imports
  class UploaderService
    include FormattedError

    attr_reader :import_user, :import_user_hash, :message

    def initialize(json_content)
      @json_content = json_content
      @message      = "#execute has not been called!"
    end

    def execute
      set_import_user_hash
      set_import_user if successful?

      self
    end

    def successful?
      @message.blank?
    end

    private

    def set_import_user_hash
      begin
        @import_user_hash = JSON.parse(@json_content).with_indifferent_access
        @message = nil
      rescue JSON::ParserError => e
        @message = format_error("Invalid JSON file", error: e)
      rescue => e
        @message = format_error("Error processing file", error: e)
      end
    end

    def set_import_user
      begin
        username = @import_user_hash.dig(:user, :username)
        @import_user = User.find_by!(username: username)
        @message = nil
      rescue ActiveRecord::RecordNotFound => e
        @message = format_error("Import user '#{username}' not found", error: e)
      rescue => e
        @message = format_error("Error finding import user '#{username}'", error: e)
      end
    end
  end
end
