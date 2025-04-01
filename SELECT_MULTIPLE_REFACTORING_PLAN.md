# Select Multiple Functionality Refactoring Plan

This document outlines the plan for refactoring the "select multiple" functionality across user resources (foods, health goals, health conditions) to follow a more consistent and maintainable pattern.

## Current Issues

1. **Inconsistent Directory Structure**:
   - The code for handling multiple selection is scattered across different files and controllers
   - No clear pattern for where search-related partials should live

2. **Duplicated Logic**:
   - Each controller has almost identical `select_multiple` and `add_multiple` methods
   - Search field partials have duplicate code with minor differences

3. **Inconsistent Render Paths**:
   - Some views reference partials with direct paths, others use relative paths
   - Some use `_*_list_frame` while others use different naming conventions

4. **Javascript Controller Issues**:
   - Hard-coded frame IDs and paths in JavaScript controllers
   - Modal controller has hardcoded item types and path checks

## Proposed New Structure

### 1. View Organization

Create a consistent directory structure for selection-related views:

```
app/views/
  user_foods/
    select/
      _modal.html.erb        # Modal content
      _list.html.erb         # List of items to select
      _search_field.html.erb # Search field component
  user_health_goals/
    select/
      _modal.html.erb
      _list.html.erb
      _search_field.html.erb
  user_health_conditions/
    select/
      _modal.html.erb
      _list.html.erb
      _search_field.html.erb
```

### 2. Create Shared Base Components

Implement shared components that can be specialized:

```
app/views/shared/
  select/
    _modal_base.html.erb     # Base modal template with yield points
    _search_field_base.html.erb # Base search field with customization points
    _select_all_controls.html.erb # Common select all/none controls
```

### 3. Controller Refactoring

Extract common controller logic into a shared concern:

```ruby
# app/controllers/concerns/multiple_selection.rb
module MultipleSelection
  extend ActiveSupport::Concern

  def select_multiple
    # Get items based on resource_type
    @items = search_service_for(resource_type, current_user, params[:search])

    respond_to do |format|
      format.html do
        if turbo_frame_request? && params[:frame_id] == list_frame_id
          render "#{resource_path}/select/list", locals: { items: @items }
        elsif turbo_frame_request?
          render "#{resource_path}/select/modal", locals: { items: @items }
        end
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          list_frame_id,
          partial: "#{resource_path}/select/list",
          locals: { items: @items }
        )
      end
    end
  end

  def add_multiple
    item_ids = params["#{resource_type}_ids"]&.reject(&:blank?)
    
    if item_ids.blank?
      handle_empty_selection
      return
    end

    begin
      count = add_items_to_user(item_ids)
      handle_successful_addition(count)
    rescue => e
      handle_error(e)
    end
  end

  private

  # These methods should be implemented by including controllers
  def resource_type
    # e.g., "food", "health_goal", "health_condition"
    raise NotImplementedError
  end

  def resource_path
    # e.g., "user_foods", "user_health_goals", "user_health_conditions"
    raise NotImplementedError
  end

  def list_frame_id
    # e.g., "foods_list", "goals_list", "conditions_list"
    "#{resource_type.pluralize}_list"
  end

  def search_service_for(type, user, query)
    case type
    when "food"
      SearchService.search_foods(user, query)
    when "health_goal"
      SearchService.search_health_goals(user, query)
    when "health_condition"
      SearchService.search_health_conditions(user, query)
    end
  end

  # Common handler methods
  def handle_empty_selection
    error_message = "Please select at least one #{resource_type}."
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

  def handle_successful_addition(count)
    message = "#{count} #{resource_type.pluralize(count)} successfully added."
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
            locals: { "#{resource_path}": current_user.send(resource_path).ordered_scope }
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

  def handle_error(exception)
    error_message = "Error adding #{resource_type.pluralize}: #{exception.message}"
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

  # This should be implemented by including controllers
  def add_items_to_user(item_ids)
    raise NotImplementedError
  end
end
```

### 4. JavaScript Refactoring

Create a more flexible and consistent approach:

```javascript
// app/javascript/controllers/search_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class SearchFormController extends Controller {
  static targets = ["input", "container"];
  static values = {
    debounce: { type: Number, default: 200 },
    resourceType: String, // "food", "health_goal", "health_condition"
    searchPath: String,
    listFrameId: String
  };
  
  // ... implementation
}

// app/javascript/controllers/select_controller.js
import { Controller } from "@hotwired/stimulus"

export default class SelectController extends Controller {
  static targets = ["submitButton", "selectionCount", "selectAllButton", "selectNoneButton"];
  static values = {
    selectedItems: { type: Array, default: [] },
    itemType: String, // "food", "health_goal", "health_condition"
    itemTypeLabel: String // Display name for the item type
  };
  
  // ... implementation
}
```

## Implementation Steps

### 1. Create Base Files

1. Create the directory structure:
```
mkdir -p app/views/shared/select
mkdir -p app/views/user_foods/select
mkdir -p app/views/user_health_goals/select
mkdir -p app/views/user_health_conditions/select
```

2. Create the shared base templates
3. Create the concerns/multiple_selection.rb file

### 2. Implement for User Foods

1. Create the specialized views in user_foods/select/
2. Update the UserFoodsController to include MultipleSelection concern
3. Update the JavaScript controller references
4. Test food selection functionality

### 3. Implement for User Health Goals

1. Create the specialized views in user_health_goals/select/
2. Update the UserHealthGoalsController to include MultipleSelection concern
3. Update the JavaScript controller references
4. Test health goal selection functionality

### 4. Implement for User Health Conditions

1. Create the specialized views in user_health_conditions/select/
2. Update the UserHealthConditionsController to include MultipleSelection concern
3. Update the JavaScript controller references
4. Test health condition selection functionality

### 5. Cleanup

1. Remove deprecated partials and views
2. Update any tests to reflect the new structure
3. Update documentation

## Testing Strategy

1. Run the specific controller tests before each implementation
2. Verify functionality after each controller is updated
3. Run full test suite after completing all changes
4. Manually test the selection and search functionality

## Benefits

1. **Improved Code Organization**:
   - Clear directory structure for selection-related components
   - Consistent pattern across all resource types

2. **Reduced Duplication**:
   - Common logic extracted to shared components and concerns
   - Less code to maintain and update

3. **Better Maintainability**:
   - Adding new selectable resources will be much easier
   - Changes to selection behavior can be made in one place

4. **Consistent User Experience**:
   - All selection interfaces will work the same way
   - Improved reliability and predictability for users