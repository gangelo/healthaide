# frozen_string_literal: true

# The MultipleSelection concern provides common functionality for controllers
# that need to handle multiple selection and addition of resources.
module MultipleSelection
  extend ActiveSupport::Concern

  # Handle the select_multiple action for selecting items
  def select_multiple
    @items = search_items_for_user(params[:search])

    respond_to do |format|
      format.html do
        if turbo_frame_request? && params[:frame_id] == list_frame_id
          render "#{resource_path}/select/list_frame", locals: { items_local_name => @items }
        elsif turbo_frame_request?
          render partial: "#{resource_path}/select/modal", locals: { items_local_name => @items }
        end
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          list_frame_id,
          partial: "#{resource_path}/select/list_frame",
          locals: { items_local_name => @items }
        )
      end
    end
  end

  # Handle the add_multiple action for adding selected items
  def add_multiple
    item_ids = params["#{item_id_param_name}"]&.reject(&:blank?)
    
    if item_ids.blank?
      handle_empty_selection
      return
    end

    begin
      items_added = add_items_to_user(item_ids)
      success_message = "#{items_added} #{resource_type.to_s.humanize.downcase.pluralize(items_added)} successfully added."
      handle_successful_addition(success_message)
    rescue => e
      handle_error(e)
    end
  end

  private

  # Method to search for items based on user and query
  # Should be implemented by including class or overridden here
  def search_items_for_user(query)
    search_service.search_for_resource(current_user, query)
  end

  # The search service to use - can be overridden
  def search_service
    SearchService
  end

  # Resource type (e.g., :food, :health_goal, :health_condition)
  # Must be implemented by including class
  def resource_type
    raise NotImplementedError, "#{self.class} must implement #resource_type"
  end

  # Resource path for views (e.g., "user_foods", "user_health_goals")
  # Must be implemented by including class
  def resource_path
    raise NotImplementedError, "#{self.class} must implement #resource_path"
  end

  # The name of the param that contains the IDs of selected items
  # Can be overridden if it doesn't follow the standard pattern
  def item_id_param_name
    "#{resource_type}_ids"
  end

  # The local variable name to use in view templates
  # Can be overridden if it doesn't follow the standard pattern
  def items_local_name
    resource_type.to_s.pluralize
  end

  # The ID of the turbo frame that contains the list of items
  # Can be overridden if it doesn't follow the standard pattern
  def list_frame_id
    "#{resource_type.to_s.pluralize}_list"
  end

  # Handle the case when no items are selected
  def handle_empty_selection
    error_message = "Please select at least one #{resource_type.to_s.humanize.downcase}."
    respond_to do |format|
      format.turbo_stream do
        flash[:alert] = error_message
        render turbo_stream: turbo_stream.update(
          "flash_messages",
          partial: "shared/flash_messages"
        )
      end
      format.html do
        redirect_to send("#{resource_path}_path"), alert: error_message
      end
    end
  end

  # Handle successful addition of items
  def handle_successful_addition(message)
    respond_to do |format|
      format.turbo_stream do
        flash[:notice] = message
        render turbo_stream: [
          turbo_stream.update(
            "flash_messages",
            partial: "shared/flash_messages"
          ),
          turbo_stream.update(
            "main_content",
            partial: "#{resource_path}/list/list",
            locals: { "#{user_items_local_name}" => current_user_items }
          ),
          turbo_stream.replace(
            "modal",
            partial: "shared/empty_frame"
          )
        ]
      end
      format.html do
        redirect_to send("#{resource_path}_path"), notice: message
      end
    end
  end

  # Handle errors during item addition
  def handle_error(exception)
    error_message = "Error adding #{resource_type.to_s.humanize.downcase.pluralize}: #{exception.message}"
    respond_to do |format|
      format.turbo_stream do
        flash[:alert] = error_message
        render turbo_stream: turbo_stream.update(
          "flash_messages",
          partial: "shared/flash_messages"
        )
      end
      format.html do
        redirect_to send("#{resource_path}_path"), alert: error_message
      end
    end
  end

  # Get the current user's items
  # Can be overridden if the association doesn't follow standard naming
  def current_user_items
    current_user.send(resource_path).ordered_scope
  end

  # The local variable name for the current user's items
  # Can be overridden if it doesn't follow standard naming
  def user_items_local_name
    resource_path
  end

  # Add selected items to the user
  # Must be implemented by including class
  def add_items_to_user(item_ids)
    raise NotImplementedError, "#{self.class} must implement #add_items_to_user"
  end
end