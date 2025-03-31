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

  # Generate HTML for a flash message with appropriate styling based on type
  def flash_message_tag(type, message)
    flash_type = flash_type_for(type)
    flash_css_class = flash_container_css_class_for(flash_type)
    flash_svg = svg_icon_container_for_flash_type(flash_type) do
      icon_for_flash_type(flash_type)
    end

    content_tag(:div, class: "flash-message-container rounded-md p-4 mb-4 #{flash_css_class}") do
      content_tag(:div, class: "flex") do
        content_tag(:div, class: "flex-shrink-0") do
          raw(flash_svg)
        end +
        content_tag(:div, class: "ml-2") do
          content_tag(:span, message, class: "text-sm font-medium")
        end
      end
    end
  end

  private

  def icon_for_flash_type(type)
    case type
    when "notice", "success"
      '<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>'
    when "alert", "error"
      '<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>'
    when "warning"
      '<path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>'
    when "info"
      '<path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>'
    else
      '<path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>'
    end
  end

  def svg_icon_container_for_flash_type(type, &block)
    icon = block.call
    <<~SVG
      <svg class="#{svg_icon_container_css_class_for(type)}" viewBox="0 0 20 20" fill="currentColor">
        #{icon}
      </svg>
    SVG
  end

  def svg_icon_container_css_class_for(type)
    case type
    when "notice"
      "flash-notice-icon"
    when "success"
      "flash-success-icon"
    when "alert"
      "flash-alert-icon"
    when "error"
      "flash-error-icon"
    when "warning"
      "flash-warning-icon"
    when "info"
      "flash-info-icon"
    else
      "flash-other-icon"
    end
  end

  def flash_container_css_class_for(type)
    case type
    when "notice"
      "flash-notice"
    when "success"
      "flash-success"
    when "alert"
      "flash-alert"
    when "error"
      "flash-error"
    when "warning"
      "flash-warning"
    when "info"
      "flash-info"
    else
      # TODO: Raise an error here?
      "flash-other"
    end
  end

  def flash_type_for(type)
    return type if %w[alert error info notice success warning].include?(type)

    "other"
  end
end
