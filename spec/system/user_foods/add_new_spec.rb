# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Adding new foods", type: :system do
  let(:user) { create(:user) }
  let!(:existing_food) { create(:food, food_name: "Apple") }

  before do
    user.confirm
    sign_in user
  end

  scenario "User can navigate to the new food form" do
    visit user_foods_path

    # NOTE: We need to match: :first because there are no foods in the list yet
    # and the "Add" button appears twice in the UI.
    click_link "Add Foods", match: :first

    expect(page).to have_content("Add Foods")
    expect(page).to have_content("Available Foods")
    expect(page).to have_content("Selected Foods")
    expect(page).to have_button("Add Selected Foods", disabled: true)
  end

  scenario "User can create a new food", js: true do
    visit new_user_food_path

    # First search for a non-existent food to trigger the new food form
    fill_in "Search foods...", with: "Broccoli"

    # Add New Food form should appear
    expect(page).to have_content("Add New Food")

    # Create new food
    within("[data-food-selection-target='newFoodForm']") do
      fill_in "Enter food name", with: "Broccoli"
      click_button "Add"
    end

    # Submit the form
    click_button "Add Selected Foods"

    # Verify the result
    expect(page).to have_current_path(user_foods_path)
    expect(page).to have_content("successfully added")
    expect(page).to have_content("Broccoli")
  end

  scenario "User cannot create a food with an empty name", js: true do
    visit new_user_food_path

    # First search for a non-existent food to trigger the new food form
    fill_in "Search foods...", with: "EmptyFood"

    # Add New Food form should appear
    expect(page).to have_content("Add New Food")

    # Try to create new food with empty name
    within("[data-food-selection-target='newFoodForm']") do
      fill_in "Enter food name", with: ""
      click_button "Add"
    end

    # The empty food won't be added to selected foods
    expect(page).to have_button("Add Selected Foods", disabled: true)
  end

  scenario "User cannot add a food with an invalid name", js: true do
    visit new_user_food_path

    # First search for an existing food
    fill_in "Search foods...", with: "1nvali4 n$me"

    # Add form should appear
    expect(page).to have_content("Add New Food")

    within("[data-food-selection-target='newFoodForm']") do
      # find_button("Add", match: :first).click
      find("button[data-action='click->food-selection#addNewFood']").click
    end

    within("[data-food-selection-target='selectedList']") do
      expect(page).to have_content("1nvali4 n$me")
    end

    within("[data-food-selection-target='form']") do
      # find(["button[data-food-selection-target='submitButton']").click
      click_button "commit"
    end

    expect(page).to have_content(Food::INVALID_NAME_REGEX_MESSAGE)
  end
end
