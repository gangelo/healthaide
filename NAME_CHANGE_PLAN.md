# View Organization Refactoring Plan

This document outlines the plan for refactoring view partials to follow a more consistent naming convention and directory structure, along with the necessary backend and test changes.

## Current vs. Proposed Structure

### Current Structure
- `app/views/user_foods/user_foods_list/_list.html.erb`
- `app/views/user_foods/user_foods_list/_row.html.erb`
- `app/views/user_foods/user_foods_list/_row_food_qualifiers.html.erb`

### Proposed Structure
- `app/views/user_foods/list/_list.html.erb`
- `app/views/user_foods/list/_row.html.erb`
- `app/views/user_foods/list/_row_food_qualifiers.html.erb`

This change removes redundancy in naming and follows a more logical grouping pattern.

## Files to Create/Rename

### 1. Create new directories and files
```
mkdir -p app/views/user_foods/list
mkdir -p app/views/user_health_conditions/list
mkdir -p app/views/user_health_goals/list
```

### 2. Move files to new locations
```
cp app/views/user_foods/user_foods_list/_list.html.erb app/views/user_foods/list/_list.html.erb
cp app/views/user_foods/user_foods_list/_row.html.erb app/views/user_foods/list/_row.html.erb
cp app/views/user_foods/user_foods_list/_row_food_qualifiers.html.erb app/views/user_foods/list/_row_food_qualifiers.html.erb
```

## Controller Changes

### Update UserFoodsController
- Change references in the `destroy` method:
```ruby
turbo_stream.update("main_content",
  partial: "user_foods/list/list",
  locals: { user_foods: @user_foods })
```

- Change references in the `add_multiple` method:
```ruby
turbo_stream.update(
  "main_content",
  partial: "user_foods/list/list",
  locals: { user_foods: current_user.user_foods.includes(:food).ordered }
)
```

### Apply similar changes to UserHealthConditionsController and UserHealthGoalsController
- Update any methods that render partials to use the new structure
- Ensure consistent use of the `main_content` Turbo frame across all controllers

## View Changes

### Update index.html.erb
```erb
<%= turbo_frame_tag "main_content" do %>
  <%= render "user_foods/list/list", user_foods: @user_foods %>
<% end %>
```

### Update internal references in partials
- In `_list.html.erb`:
```erb
<%= render partial: "user_foods/list/row", locals: { user_foods: user_foods } %>
```

- In `_row.html.erb`:
```erb
<%= render partial: "user_foods/list/row_food_qualifiers", locals: { food: user_food.food } %>
```

## Test Changes

### Update system tests
- Inspect and update tests that may be using now-changed element selectors
- Ensure all feature tests that interact with lists are updated
- Add test coverage for new Turbo frame updates

```ruby
# Example system test update
it "removes the food and updates the list via Turbo", js: true do
  visit user_foods_path
  
  within "#main_content" do
    expect(page).to have_content(food.food_name)
    
    within("li", text: food.food_name) do
      accept_confirm do
        click_button "Delete"
      end
    end
    
    # Should stay on same page but content updates via Turbo
    expect(page).to have_content("Food was successfully removed")
    expect(page).not_to have_content(food.food_name)
  end
end
```

## Implementation Strategy

1. **Create backup branch**:
   ```
   git checkout -b view-backup
   git add .
   git commit -m "Backup before view refactoring"
   git checkout -b view-refactoring
   ```

2. **Create new directory structure**:
   - Create the new directories and files as outlined above

3. **Update controllers**:
   - Modify controllers to use the new partial paths

4. **Update tests**:
   - Fix any broken tests to account for new structure

5. **Test extensively**:
   - Run full test suite to ensure functionality is preserved
   - Manually test all affected features

6. **Remove old files**:
   - Once everything is working, delete the old directories and files

7. **Document changes**:
   - Update CLAUDE.md with new conventions
   - Add explanatory comments to key files

## Important Notes

- Keep both old and new files in place temporarily to allow for easy rollback if issues arise
- Only remove old files once new structure is fully tested
- Consider doing this refactoring in smaller, focused PRs if the scope becomes too large