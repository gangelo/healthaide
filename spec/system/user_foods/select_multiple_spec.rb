# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Selecting multiple foods", type: :system do
  let(:user) { create(:user) }
  let!(:food1) { create(:food, food_name: "Apple") }
  let!(:food2) { create(:food, food_name: "Banana") }
  let!(:food3) { create(:food, food_name: "Cherry") }
  let!(:food4) { create(:food, food_name: "Dragon Fruit") }
  
  # Food with qualifier
  let!(:food_with_qualifier) do
    food = create(:food, food_name: "Avocado")
    food.food_qualifiers << create(:food_qualifier, qualifier_name: "Organic")
    food
  end

  before do
    user.confirm
    sign_in user
    # Add one food to the user
    create(:user_food, user: user, food: food1)
  end

  scenario "User can open the multiple selection modal", js: true do
    visit new_user_food_path
    
    click_link "Choose Multiple Foods"
    
    expect(page).to have_content("Select Foods")
    expect(page).to have_content(food2.food_name)
    expect(page).to have_content(food3.food_name)
    expect(page).to have_content(food4.food_name)
    expect(page).to have_content(food_with_qualifier.food_name)
    expect(page).not_to have_content(food1.food_name) # Already added
    
    # Should display qualifiers if present
    expect(page).to have_content("Organic")
  end

  scenario "User can search for foods in the modal", js: true do
    visit new_user_food_path
    
    click_link "Choose Multiple Foods"
    
    # Search for specific term
    fill_in "Search foods...", with: "dragon"
    
    # Wait for results to update
    expect(page).to have_content(food4.food_name) # "Dragon Fruit"
    expect(page).not_to have_content(food2.food_name) # "Banana"
    expect(page).not_to have_content(food3.food_name) # "Cherry"
  end

  scenario "User can select multiple foods", js: true do
    visit new_user_food_path
    
    click_link "Choose Multiple Foods"
    
    # Select multiple foods using checkboxes
    check "food_ids_#{food2.id}"
    check "food_ids_#{food4.id}"
    
    # Click add button
    click_button "Add Selected Foods"
    
    # Verify result
    expect(page).to have_current_path(user_foods_path)
    expect(page).to have_content("2 foods successfully added")
    expect(page).to have_content(food2.food_name)
    expect(page).to have_content(food4.food_name)
  end

  scenario "User cannot submit without selecting any foods", js: true do
    visit new_user_food_path
    
    click_link "Choose Multiple Foods"
    
    # Don't select any checkboxes
    
    # Add button should be disabled
    expect(page).to have_button("Add Selected Foods", disabled: true)
  end

  scenario "User can use select all button", js: true do
    visit new_user_food_path
    
    click_link "Choose Multiple Foods"
    
    # Use select all button
    click_button "Select All"
    
    # All available checkboxes should be checked
    expect(page).to have_checked_field("food_ids_#{food2.id}")
    expect(page).to have_checked_field("food_ids_#{food3.id}")
    expect(page).to have_checked_field("food_ids_#{food4.id}")
    expect(page).to have_checked_field("food_ids_#{food_with_qualifier.id}")
    
    # Add button should be enabled
    expect(page).to have_button("Add Selected Foods", disabled: false)
  end

  scenario "User can use select none button", js: true do
    visit new_user_food_path
    
    click_link "Choose Multiple Foods"
    
    # First select all
    click_button "Select All"
    
    # Then deselect all
    click_button "Select None"
    
    # No checkboxes should be checked
    expect(page).to have_unchecked_field("food_ids_#{food2.id}")
    expect(page).to have_unchecked_field("food_ids_#{food3.id}")
    expect(page).to have_unchecked_field("food_ids_#{food4.id}")
    
    # Add button should be disabled again
    expect(page).to have_button("Add Selected Foods", disabled: true)
  end

  scenario "User can cancel the modal", js: true do
    visit new_user_food_path
    
    click_link "Choose Multiple Foods"
    
    # Check modal is open
    expect(page).to have_content("Select Foods")
    
    # Click cancel
    click_link "Cancel"
    
    # Modal should be closed
    expect(page).not_to have_content("Select Foods")
    expect(page).to have_current_path(new_user_food_path)
  end
end