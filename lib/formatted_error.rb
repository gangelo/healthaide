# frozen_string_literal: true

module FormattedError
  module_function

  def format_error(error_message, error:)
    return "#{error_message}." unless Rails.env.local?

    "#{error_message}: #{error.message}."
  end
end
