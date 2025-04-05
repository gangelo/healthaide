# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Adding new foods", type: :system do
  let(:user) { create(:user) }
  let!(:existing_food) { create(:food, food_name: "Apple") }
  let!(:soft_deleted_food) { create(:food, :soft_deleted, food_name: "Deleted Food") }

  before do
    user.confirm
    sign_in user
  end

  scenario "User can navigate to the new food form" do
    visit user_foods_path

    # NOTE: We need to match: :first because there are no foods in the list yet
    # and the "Add Food" button appears twice in the UI.
    click_link "Add Food", match: :first

    expect(page).to have_content("Add Food")
    expect(page).to have_content("Create New Food")
    expect(page).to have_content("Select Existing Food")
    expect(page).to have_content("Add Multiple Foods")
  end

  scenario "User can create a new food" do
    visit new_user_food_path

    # Choose the create new food option
    within("#create-new-food") do
      fill_in "user_food[new_food_name]", with: "Broccoli"
      click_button "Create & Add New Food"
    end

    # Verify the result
    expect(page).to have_current_path(user_foods_path)
    expect(page).to have_content("Food was successfully added to your list")
    expect(page).to have_content("Broccoli")
  end

  scenario "User cannot create a food with an empty name" do
    visit new_user_food_path

    # Try to submit with empty name
    within("#create-new-food") do
      fill_in "user_food[new_food_name]", with: ""
      click_button "Create & Add New Food"
    end

    # Should see validation error
    expect(page).to have_content("Please select an existing food or enter a new food name")
  end

  scenario "User can restore a soft-deleted food" do
    visit new_user_food_path

    # Create food with same name as soft-deleted food
    within("#create-new-food") do
      fill_in "user_food[new_food_name]", with: soft_deleted_food.food_name
      click_button "Create & Add New Food"
    end

    expect(page).to have_current_path(user_foods_path)

    # Should see restoration message
    within("#flash_messages") do
      expect(page).to have_content("Food was successfully added to your list.")
    end

    within("#main_content") do
      expect(page).to have_content(soft_deleted_food.food_name)
    end
  end
end
