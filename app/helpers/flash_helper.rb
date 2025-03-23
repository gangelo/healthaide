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
    css_class = case type.to_s
                when "notice", "success"
                  "bg-green-50 text-green-800 border border-green-200"
                when "alert", "error"
                  "bg-red-50 text-red-800 border border-red-200"
                when "warning"
                  "bg-amber-50 text-amber-800 border border-amber-200"
                when "info"
                  "bg-blue-50 text-blue-800 border border-blue-200"
                else
                  "bg-gray-50 text-gray-800 border border-gray-200"
                end

    icon = case type.to_s
           when "notice", "success"
             '<svg class="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>'
           when "alert", "error"
             '<svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
              </svg>'
           when "warning"
             '<svg class="h-5 w-5 text-amber-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
              </svg>'
           when "info"
             '<svg class="h-5 w-5 text-blue-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
              </svg>'
           else
             '<svg class="h-5 w-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
              </svg>'
           end

    content_tag(:div, class: "rounded-md p-4 mb-4 #{css_class}") do
      content_tag(:div, class: "flex") do
        content_tag(:div, class: "flex-shrink-0") do
          raw(icon)
        end +
        content_tag(:div, class: "ml-3") do
          content_tag(:p, message, class: "text-sm font-medium")
        end
      end
    end
  end
end