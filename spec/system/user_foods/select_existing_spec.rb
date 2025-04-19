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

  scenario "User can see available foods", js: true do
    visit new_user_food_path

    # Check available foods list
    within("[data-food-selection-target='availableList']") do
      # Should include foods not already added
      expect(page).to have_content(food2.food_name)
      expect(page).to have_content(food3.food_name)
      expect(page).to have_content(food_with_qualifiers.food_name)

      # Food with qualifiers should be present
      expect(page).to have_content(food_with_qualifiers.food_name)

      # Should not include already added foods
      expect(page).not_to have_content(food1.food_name)
    end
  end

  scenario "User can select an existing food", js: true do
    visit new_user_food_path

    # Click on a food to select it
    find("[data-food-id='#{food2.id}']").click

    # Check it's moved to the selected foods list
    within("[data-food-selection-target='selectedList']") do
      expect(page).to have_content(food2.food_name)
    end

    # Submit the form
    click_button "Add Selected Foods"

    # Verify the result
    expect(page).to have_current_path(user_foods_path)
    expect(page).to have_content("successfully added")
    expect(page).to have_content(food2.food_name)
  end

  scenario "User must select a food", js: true do
    visit new_user_food_path

    # Don't select any foods
    expect(page).to have_button("Add Selected Foods", disabled: true)
  end

  scenario "User can navigate back to list" do
    visit new_user_food_path

    click_link "Back to My Foods"

    expect(page).to have_current_path(user_foods_path)
  end
end
