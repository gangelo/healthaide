module FlashHelper
  # Get all flash messages including notice/alert that might not be in the flash hash
  def all_flash_messages
    messages = []

    # Add all messages from the flash hash
    flash.each do |type, message|
      messages << { type: type, message: message } if message.present?
    end

    # Add notice if it exists but isn't already in flash
    if notice.present? && !flash[:notice]
      messages << { type: "notice", message: notice }
    end

    # Add alert if it exists but isn't already in flash
    if alert.present? && !flash[:alert]
      messages << { type: "alert", message: alert }
    end

    messages
  end

  # Generate HTML for a flash message
  def flash_message_tag(type, message)
    content_tag(:div, message,
                class: "flash-message #{type} py-2 px-3 mb-5 font-medium rounded-lg inline-block")
  end
end
