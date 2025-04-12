# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Selecting multiple health conditions", type: :system do
  let(:user) { create(:user) }
  let!(:health_condition1) { create(:health_condition, health_condition_name: "Diabetes") }
  let!(:health_condition2) { create(:health_condition, health_condition_name: "Hypertension") }
  let!(:health_condition3) { create(:health_condition, health_condition_name: "Asthma") }
  let!(:health_condition4) { create(:health_condition, health_condition_name: "Arthritis") }

  before do
    user.confirm
    sign_in user
    # Add one health condition to the user
    create(:user_health_condition, user: user, health_condition: health_condition1)
  end

  scenario "User can see available health conditions", js: true do
    visit new_user_health_condition_path

    # The new interface is always showing the selection UI directly on the page
    expect(page).to have_content("Available Health Conditions")
    expect(page).to have_content("Selected Health Conditions")
    
    # Check conditions are displayed
    within("[data-health-condition-selection-target='availableList']") do
      expect(page).to have_content(health_condition2.health_condition_name)
      expect(page).to have_content(health_condition3.health_condition_name)
      expect(page).to have_content(health_condition4.health_condition_name)
      expect(page).not_to have_content(health_condition1.health_condition_name) # Already added
    end
  end

  scenario "User can search for health conditions", js: true do
    visit new_user_health_condition_path

    # Search for specific term
    fill_in "Search health conditions...", with: "arth"

    # Wait for results to update
    within("[data-health-condition-selection-target='availableList']") do
      expect(page).to have_content(health_condition4.health_condition_name) # "Arthritis"
      expect(page).not_to have_content(health_condition2.health_condition_name) # "Hypertension"
      expect(page).not_to have_content(health_condition3.health_condition_name) # "Asthma"
    end
  end

  scenario "User can select multiple health conditions", js: true do
    visit new_user_health_condition_path

    # Select multiple conditions by clicking them
    find("[data-condition-id='#{health_condition2.id}']").click
    find("[data-condition-id='#{health_condition4.id}']").click

    # Verify they moved to selected list
    within("[data-health-condition-selection-target='selectedList']") do
      expect(page).to have_content(health_condition2.health_condition_name)
      expect(page).to have_content(health_condition4.health_condition_name)
    end

    # Click add button
    click_button "Add Selected Conditions"

    # Verify result
    expect(page).to have_current_path(user_health_conditions_path)
    expect(page).to have_content("successfully added")
    expect(page).to have_content(health_condition2.health_condition_name)
    expect(page).to have_content(health_condition4.health_condition_name)
  end

  scenario "User cannot submit without selecting any conditions", js: true do
    visit new_user_health_condition_path

    # Don't select any conditions
    # Add button should be disabled
    expect(page).to have_button("Add Selected Conditions", disabled: true)
  end

  scenario "User can use the Clear All button", js: true do
    visit new_user_health_condition_path

    # Select a couple conditions first
    find("[data-condition-id='#{health_condition2.id}']").click
    find("[data-condition-id='#{health_condition4.id}']").click
    
    # Verify selection
    within("[data-health-condition-selection-target='selectedList']") do
      expect(page).to have_content(health_condition2.health_condition_name)
      expect(page).to have_content(health_condition4.health_condition_name)
    end
    
    # Now clear all
    click_button "Clear All"
    
    # No conditions should be in the selected list
    within("[data-health-condition-selection-target='selectedList']") do
      expect(page).not_to have_content(health_condition2.health_condition_name)
      expect(page).not_to have_content(health_condition4.health_condition_name)
    end
    
    # Conditions should be back in the available list
    within("[data-health-condition-selection-target='availableList']") do
      expect(page).to have_content(health_condition2.health_condition_name)
      expect(page).to have_content(health_condition4.health_condition_name)
    end

    # Add button should be disabled again
    expect(page).to have_button("Add Selected Conditions", disabled: true)
  end

  scenario "User can navigate back to health conditions list", js: true do
    visit new_user_health_condition_path

    # Click the back link
    click_link "Back to My Health Conditions"

    # Should return to health conditions list
    expect(page).to have_current_path(user_health_conditions_path)
  end
end
