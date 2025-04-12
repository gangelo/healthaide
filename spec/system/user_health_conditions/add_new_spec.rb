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

    # NOTE: We need to match: :first because there are no conditions in the list yet
    # and the "Add" button appears twice in the UI.
    click_link "Add Health Condition", match: :first

    expect(page).to have_current_path(new_user_health_condition_path)

    # Check that the new UI is displayed with dual panel selection
    expect(page).to have_content("Available Health Conditions")
    expect(page).to have_content("Selected Health Conditions")
    expect(page).to have_button("Add Selected Conditions", disabled: true)
  end

  scenario "User can create a new health condition using search", js: true do
    visit new_user_health_condition_path

    # Search for a condition that doesn't exist
    fill_in "Search health conditions...", with: "Arthritis"
    
    # Wait for the "Add New Health Condition" form to appear
    expect(page).to have_content("This health condition doesn't exist yet")
    
    # Create new condition through the "Add New" form
    within("[data-health-condition-selection-target='newConditionForm']") do
      # The input should be pre-filled with the search term
      expect(find("[data-health-condition-selection-target='newConditionInput']").value).to eq("Arthritis")
      click_button "Add"
    end
    
    # Submit the form to add the new condition
    click_button "Add Selected Conditions"

    # Verify the result
    expect(page).to have_current_path(user_health_conditions_path)
    expect(page).to have_content("successfully added")
    expect(page).to have_content("Arthritis")
  end

  scenario "User cannot create a health condition with an empty name", js: true do
    visit new_user_health_condition_path

    # Try to search with empty string, which shouldn't show the "Add New" form
    fill_in "Search health conditions...", with: ""
    
    # The "Add New" form should not be visible
    expect(page).not_to have_css("[data-health-condition-selection-target='newConditionForm']:not(.hidden)")
  end

  scenario "User cannot create a duplicate health condition", js: true do
    visit new_user_health_condition_path

    # Search for an existing condition
    fill_in "Search health conditions...", with: existing_health_condition.health_condition_name
    
    # The condition should appear in the available list and not in the "Add New" form
    expect(page).to have_content(existing_health_condition.health_condition_name)
    expect(page).not_to have_css("[data-health-condition-selection-target='newConditionForm']:not(.hidden)")
  end
end
