# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Adding new health conditions", type: :system do
  let(:user) { create(:user) }
  let!(:existing_health_condition) { create(:health_condition, health_condition_name: "Diabetes") }

  before do
    user.confirm
    sign_in user
  end

  scenario "User can navigate to the new health condition form" do
    visit user_health_conditions_path
    click_link "Add Health Condition"

    expect(page).to have_content("Add Health Condition")
    expect(page).to have_content("Create New Health Condition")
    expect(page).to have_content("Select Existing Health Condition")
    expect(page).to have_content("Add Multiple Health Conditions")
  end

  scenario "User can create a new health condition" do
    visit new_user_health_condition_path

    # Choose the create new condition option
    within("#create-new-condition") do
      fill_in "user_health_condition[new_health_condition_name]", with: "Arthritis"
      click_button "Create & Add New Health Condition"
    end

    # Verify the result
    expect(page).to have_current_path(user_health_conditions_path)
    expect(page).to have_content("Health condition was successfully added")
    expect(page).to have_content("Arthritis")
  end

  scenario "User cannot create a health condition with an empty name" do
    visit new_user_health_condition_path

    # Try to submit with empty name
    within("#create-new-condition") do
      fill_in "user_health_condition[new_health_condition_name]", with: ""
      click_button "Create & Add New Health Condition"
    end

    # Should see validation error
    expect(page).to have_content("Health condition name can't be blank")
  end

  scenario "User cannot create a duplicate health condition" do
    visit new_user_health_condition_path

    # Try to create a health condition with an existing name
    within("#create-new-condition") do
      fill_in "user_health_condition[new_health_condition_name]", with: existing_health_condition.health_condition_name
      click_button "Create & Add New Health Condition"
    end

    # Should see validation error
    expect(page).to have_content("Health condition name has already been taken")
  end
end