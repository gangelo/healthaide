# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Selecting existing health conditions", type: :system do
  let(:user) { create(:user) }
  let!(:health_condition1) { create(:health_condition, health_condition_name: "Diabetes") }
  let!(:health_condition2) { create(:health_condition, health_condition_name: "Hypertension") }
  let!(:health_condition3) { create(:health_condition, health_condition_name: "Asthma") }

  before do
    user.confirm
    sign_in user
    # Add one health condition to the user
    create(:user_health_condition, user: user, health_condition: health_condition1)
  end

  scenario "User can see available health conditions", js: true do
    visit new_user_health_condition_path

    # Check available conditions
    within("[data-health-condition-selection-target='availableList']") do
      expect(page).to have_content(health_condition2.health_condition_name)
      expect(page).to have_content(health_condition3.health_condition_name)
      expect(page).not_to have_content(health_condition1.health_condition_name) # Already added
    end
  end

  scenario "User can select an existing health condition", js: true do
    visit new_user_health_condition_path

    # Click on a condition to select it
    find("[data-condition-id='#{health_condition2.id}']").click
    
    # Verify it moved to selected list
    within("[data-health-condition-selection-target='selectedList']") do
      expect(page).to have_content(health_condition2.health_condition_name)
    end
    
    # Submit the form
    click_button "Add Selected Conditions"

    # Verify the result
    expect(page).to have_current_path(user_health_conditions_path)
    expect(page).to have_content("successfully added")
    expect(page).to have_content(health_condition2.health_condition_name)
  end

  scenario "User cannot submit without selecting a condition", js: true do
    visit new_user_health_condition_path

    # Don't select any conditions
    # Add button should be disabled
    expect(page).to have_button("Add Selected Conditions", disabled: true)
  end

  scenario "User cannot add a health condition they already have", js: true do
    # First add health_condition2
    create(:user_health_condition, user: user, health_condition: health_condition2)

    visit new_user_health_condition_path

    # Check available conditions
    within("[data-health-condition-selection-target='availableList']") do
      expect(page).not_to have_content(health_condition1.health_condition_name) # Already added
      expect(page).not_to have_content(health_condition2.health_condition_name) # Already added
      expect(page).to have_content(health_condition3.health_condition_name) # Available
    end
  end
end
