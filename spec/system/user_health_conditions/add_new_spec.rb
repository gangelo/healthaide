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

    # NOTE: We need to match: :first because there are no foods in the list yet
    # and the "Add" button appears twice in the UI.
    click_link "Add Health Condition", match: :first

    expect(page).to have_current_path(new_user_health_condition_path)

    expect(page).to have_link("Choose Multiple Health Conditions")
    expect(page).to have_button("Add Selected Health Condition")
    expect(page).to have_button("Create & Add New Health Condition")
  end

  scenario "User can create a new health condition" do
    visit new_user_health_condition_path

    # Choose the create new condition option
    within("#create-add-new-form") do
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
    within("#create-add-new-form") do
      fill_in "user_health_condition[new_health_condition_name]", with: ""
      click_button "Create & Add New Health Condition"
    end

    # Should see validation error
    expect(page).to have_content("Health condition can't be blank")
  end

  scenario "User cannot create a duplicate health condition" do
    visit new_user_health_condition_path

    # Try to create a health condition with an existing name
    within("#create-add-new-form") do
      fill_in "user_health_condition[new_health_condition_name]", with: existing_health_condition.health_condition_name
      click_button "Create & Add New Health Condition"
    end

    # Should see validation error
    expect(page).to have_content("Health condition name has already been taken")
  end
end
