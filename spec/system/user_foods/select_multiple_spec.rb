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

  scenario "User can see available foods", js: true do
    visit new_user_food_path

    # The new interface is always showing the selection UI directly on the page
    expect(page).to have_content("Available Foods")
    expect(page).to have_content("Selected Foods")
    
    # Check foods are displayed
    within("[data-food-selection-target='availableList']") do
      expect(page).to have_content(food2.food_name)
      expect(page).to have_content(food3.food_name)
      expect(page).to have_content(food4.food_name)
      expect(page).to have_content(food_with_qualifier.food_name)
      expect(page).not_to have_content(food1.food_name) # Already added
    
      # Should display qualifiers if present
      expect(page).to have_content("Organic")
    end
  end

  scenario "User can search for foods", js: true do
    visit new_user_food_path

    # Search for specific term
    fill_in "Search foods...", with: "dragon"

    # Wait for results to update
    within("[data-food-selection-target='availableList']") do
      expect(page).to have_content(food4.food_name) # "Dragon Fruit"
      expect(page).not_to have_content(food2.food_name) # "Banana"
      expect(page).not_to have_content(food3.food_name) # "Cherry"
    end
  end

  scenario "User can select multiple foods", js: true do
    visit new_user_food_path

    # Select multiple foods by clicking them
    find("[data-food-id='#{food2.id}']").click
    find("[data-food-id='#{food4.id}']").click

    # Verify they moved to selected list
    within("[data-food-selection-target='selectedList']") do
      expect(page).to have_content(food2.food_name)
      expect(page).to have_content(food4.food_name)
    end

    # Click add button
    click_button "Add Selected Foods"

    # Verify result
    expect(page).to have_current_path(user_foods_path)
    expect(page).to have_content("successfully added")
    expect(page).to have_content(food2.food_name)
    expect(page).to have_content(food4.food_name)
  end

  scenario "User cannot submit without selecting any foods", js: true do
    visit new_user_food_path

    # Don't select any foods
    # Add button should be disabled
    expect(page).to have_button("Add Selected Foods", disabled: true)
  end

  scenario "User can use the Clear All button", js: true do
    visit new_user_food_path

    # Select a couple foods first
    find("[data-food-id='#{food2.id}']").click
    find("[data-food-id='#{food4.id}']").click
    
    # Verify selection
    within("[data-food-selection-target='selectedList']") do
      expect(page).to have_content(food2.food_name)
      expect(page).to have_content(food4.food_name)
    end
    
    # Now clear all
    click_button "Clear All"
    
    # No foods should be in the selected list
    within("[data-food-selection-target='selectedList']") do
      expect(page).not_to have_content(food2.food_name)
      expect(page).not_to have_content(food4.food_name)
    end
    
    # Foods should be back in the available list
    within("[data-food-selection-target='availableList']") do
      expect(page).to have_content(food2.food_name)
      expect(page).to have_content(food4.food_name)
    end

    # Add button should be disabled again
    expect(page).to have_button("Add Selected Foods", disabled: true)
  end

  scenario "User can navigate back to food list", js: true do
    visit new_user_food_path

    # Click the back link
    click_link "Back to My Foods"

    # Should return to food list
    expect(page).to have_current_path(user_foods_path)
  end
end
