# Implementation Example for UserFoods Refactoring

This document provides a concrete example of how to refactor the `user_foods` views according to the new naming convention. It includes specific code changes and file operations.

## Directory Structure Changes

### Create new directories
```bash
mkdir -p app/views/user_foods/list
```

### Create new files

1. Create `app/views/user_foods/list/_list.html.erb`:
```erb
<div class="bg-white shadow-md ring-1 ring-gray-900/5 rounded-xl overflow-hidden">
  <% if user_foods.any? %>
    <div class="divide-y divide-gray-100">
      <!-- Table header -->
      <%= render(Grids::HeaderComponent.new(columns: [:name, :qualifiers, actions: {css_class: "text-right" }])) %>
      <!-- Table rows -->
      <%= render partial: "user_foods/list/row", locals: { user_foods: user_foods } %>
    </div>
  <% else %>
    <div class="px-6 py-10 text-center text-gray-500">
      <div class="flex items-center justify-center">
        <%= render "shared/icons/smiley", size_class: "h-24 w-24", mouth_type: :frown %>
      </div>
      <h3 class="mt-2 text-sm font-semibold text-gray-900">No foods added yet</h3>
      <p class="mt-1 text-sm text-gray-500">Get started by adding foods to your list.</p>
      <div class="mt-6">
        <%= render partial: "shared/add_new_user_item_link",
          locals: {
            link_path: new_user_food_path,
            link_text: "Add Food",
          } %>
      </div>
    </div>
  <% end %>
</div>
```

2. Create `app/views/user_foods/list/_row.html.erb`:
```erb
<ul role="list">
  <% user_foods.each_with_index do |user_food, index| %>
    <li class="relative px-4 py-3 sm:px-6 grid grid-cols-3 gap-4 <%= index.odd? ? 'bg-gray-50' : 'bg-white' %> hover:bg-gray-100">
      <div class="text-sm font-semibold text-gray-900">
        <%= user_food.food.food_name %>
      </div>
      <div>
        <%= render partial: "user_foods/list/row_food_qualifiers", locals: { food: user_food.food } %>
      </div>
      <div class="text-right">
        <%= button_to user_food_path(user_food),
                  method: :delete,
                  class: "ml-2 rounded-lg py-2 px-4 text-white bg-red-600 hover:bg-red-500 font-medium cursor-pointer",
                  form: { data: { turbo_confirm: "Are you sure you want to remove this food?" } } do %>
          Delete
        <% end %>
      </div>
    </li>
  <% end %>
</ul>
```

3. Create `app/views/user_foods/list/_row_food_qualifiers.html.erb`:
```erb
<%# _food_qualifiers.html.erb %>
<% if food.food_qualifiers.any? %>
  <div class="flex flex-wrap gap-1">
    <% food.food_qualifiers.each do |qualifier| %>
      <span class="inline-flex items-center rounded-md bg-blue-50 px-2 py-0.5 text-xs font-medium text-blue-700">
        <%= qualifier.qualifier_name %>
      </span>
    <% end %>
  </div>
<% else %>
  <span class="text-sm text-gray-500">&nbsp;</span>
<% end %>
```

## Controller Updates

Update `app/controllers/user_foods_controller.rb`:

```ruby
# In the destroy method
def destroy
  @user_food.destroy
  set_user_foods

  respond_to do |format|
    format.html { redirect_to user_foods_path, notice: "Food was successfully removed." }
    format.turbo_stream do
      flash.now[:notice] = "Food was successfully removed."
      render turbo_stream: [
        turbo_stream.update("main_content",
          partial: "user_foods/list/list",  # Updated path
          locals: { user_foods: @user_foods }),
        turbo_stream.update("flash_messages",
          partial: "shared/flash_messages")
      ]
    end
  end
end

# In the add_multiple method
respond_to do |format|
  format.turbo_stream do
    # Set flash in the session so it's available
    flash[:notice] = message
    
    render turbo_stream: [
      turbo_stream.update(
        "flash_messages",
        partial: "shared/flash_messages"
      ),
      turbo_stream.update(
        "main_content",
        partial: "user_foods/list/list",  # Updated path
        locals: { user_foods: current_user.user_foods.includes(:food).ordered }
      ),
      turbo_stream.replace(
        "modal",
        partial: "shared/empty_frame"
      )
    ]
  end
  # ... other format handlers
end
```

## View Updates

Update `app/views/user_foods/index.html.erb`:

```erb
<% content_for :title, "My Foods" %>
<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-10">
  <!-- Flash messages outside of Turbo Frames -->
  <div id="flash_messages">
    <%= render "shared/flash_messages" %>
  </div>
  <div class="md:flex md:items-center md:justify-between mb-6">
    <div class="min-w-0 flex-1">
      <h2>My Foods</h2>
    </div>
    <div class="mt-4 flex md:ml-4 md:mt-0">
      <%= render partial: "shared/add_new_user_item_link",
          locals: {
            link_path: new_user_food_path,
            link_text: "Add Food",
          } %>
    </div>
  </div>
  <!-- Single content frame -->
  <%= turbo_frame_tag "main_content" do %>
    <%= render "user_foods/list/list", user_foods: @user_foods %>  <!-- Updated path -->
  <% end %>
</div>
```

## Test Updates

Update `spec/system/user_foods_controller_spec.rb`:

```ruby
describe "removing a food", js: true do
  let!(:user_food) { create(:user_food, user: user, food: food) }
  let(:food) { create(:food) }

  it "allows removing a food" do
    visit user_foods_path

    # Find the delete button for this food and click it
    within("#main_content") do
      within("li", text: food.food_name) do
        accept_confirm do
          click_button "Delete"
        end
      end
    end

    # Should stay on index page with success message
    expect(page).to have_current_path(user_foods_path)
    expect(page).to have_content("Food was successfully removed")
    expect(page).not_to have_content(food.food_name)
  end
end
```

## Cleanup (After Testing)

Once the new implementation is fully tested and confirmed working, remove the old files:

```bash
rm -r app/views/user_foods/user_foods_list
```

## Verification Steps

1. Run the tests:
```bash
bin/rails spec SPEC=spec/system/user_foods_controller_spec.rb
```

2. Start the server and manually test:
```bash
bin/dev
```

3. Verify that:
   - The foods list displays correctly
   - Deleting a food works with a proper success message
   - Adding multiple foods works
   - All Turbo frame updates are working correctly