# frozen_string_literal: true


RSpec.describe "Adding new foods", type: :system do
  let(:user) { create(:user) }
  let!(:existing_food) { create(:food, food_name: "Apple") }

  before do
    user.confirm
    sign_in user
  end

  scenario "User can navigate to the new food form" do
    visit user_foods_path

    # The button text has changed to "Add Food", but there might be multiple links
    # Use the first one - in the main section of the page
    click_link "Add Food", match: :first

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

  scenario "User cannot add a food with an invalid name" do
    # Creating a food with invalid characters should fail
    food = build(:food, food_name: "Invalid!@#$%Food")
    expect(food).not_to be_valid
    expect(food.errors[:food_name]).to include("can only contain letters, numbers, spaces, hyphens, apostrophes, commas, periods, forward slashes, plus signs and parentheses")
  end
end
