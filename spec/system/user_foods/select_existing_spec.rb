# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Selecting existing foods", type: :system do
  let(:user) { create(:user) }
  let!(:food1) { create(:food, food_name: "Apple") }
  let!(:food2) { create(:food, food_name: "Banana") }
  let!(:food3) { create(:food, food_name: "Cherry") }
  let!(:food_with_qualifiers) { 
    food = create(:food, food_name: "Avocado")
    food.food_qualifiers << create(:food_qualifier, qualifier_name: "Organic")
    food
  }

  before do
    user.confirm
    sign_in user
    # Add one food to the user
    create(:user_food, user: user, food: food1)
  end

  scenario "User can see available foods in dropdown" do
    visit new_user_food_path

    # Check dropdown options
    within("#select-existing-food") do
      dropdown_options = page.all('select#user_food_food_id option').map(&:text)
      
      # Should include foods not already added
      expect(dropdown_options).to include(food2.display_name_with_qualifiers)
      expect(dropdown_options).to include(food3.display_name_with_qualifiers)
      expect(dropdown_options).to include(food_with_qualifiers.display_name_with_qualifiers)
      
      # Should show qualifiers if present
      expect(dropdown_options).to include("Avocado (Organic)")
      
      # Should not include already added foods
      expect(dropdown_options).not_to include(food1.display_name_with_qualifiers)
    end
  end

  scenario "User can select an existing food" do
    visit new_user_food_path

    # Select from dropdown
    within("#select-existing-food") do
      select food2.display_name_with_qualifiers, from: "user_food[food_id]"
      click_button "Add Selected Food"
    end

    # Verify the result
    expect(page).to have_current_path(user_foods_path)
    expect(page).to have_content("Food was successfully added to your list")
    expect(page).to have_content(food2.food_name)
  end

  scenario "User must select a food" do
    visit new_user_food_path

    # Try to submit without selecting a food
    within("#select-existing-food") do
      # Don't select anything from dropdown
      click_button "Add Selected Food"
    end

    # Should see validation error
    expect(page).to have_content("Please select an existing food or enter a new food name")
  end

  scenario "User can navigate back to list" do
    visit new_user_food_path
    
    click_link "Cancel"
    
    expect(page).to have_current_path(user_foods_path)
  end
end